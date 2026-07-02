require('dotenv').config();

// ── Startup environment validation ──────────────────────────────────────────
const { validateEnv } = require('./config/validateEnv');
validateEnv();

// ── Sentry Initialization ───────────────────────────────────────────────────
const { initSentry, Sentry } = require('./config/sentry');
initSentry();

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const colors = require('colors');
const http = require('http');
const path = require('path');
const connectDB = require('./config/db');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorMiddleware');
const { initializeMqtt } = require('./utils/mqttService');
const { logger, requestLogger, updateRequestContext } = require('./utils/logger');
const Order = require('./models/orderModel');
const { startDispatch } = require('./controllers/orderController');
const { createProxyMiddleware } = require('http-proxy-middleware');

const app = express();
app.set('trust proxy', 1);

// MQTT Websocket Proxy (Must be before body-parser and helmet)
app.use('/mqtt', createProxyMiddleware({
  target: 'http://127.0.0.1:9001',
  ws: true,
  changeOrigin: true,
  logLevel: 'silent',
}));

const server = http.createServer(app);

// ── Security middleware ──────────────────────────────────────────────────────
app.use(helmet());

// Strict CORS — allow only listed origins
const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:5173,http://localhost:3000')
  .split(',')
  .map((o) => o.trim());

app.use(
  cors({
    origin: (origin, callback) => {
      // Allow no-origin requests (mobile apps, server-to-server)
      if (!origin) return callback(null, true);
      // Allow listed origins from env
      if (allowedOrigins.includes(origin)) return callback(null, true);
      // In development, allow all origins ONLY if explicitly opted in
      if (process.env.NODE_ENV !== 'production' && process.env.CORS_ALLOW_ALL_DEV === 'true') {
        return callback(null, true);
      }
      callback(new Error(`CORS blocked: ${origin}`));
    },
    credentials: true,
  })
);

// Rate limiting — global (by IP)
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: process.env.NODE_ENV === 'test' ? 10000 : 200,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests, please try again later.' },
  })
);

// Stricter rate limit on auth endpoints (by IP)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: process.env.NODE_ENV === 'test' ? 10000 : 20,
  message: { success: false, message: 'Too many auth attempts, try again in 15 minutes.' },
});
app.use('/api/auth', authLimiter);

// ── Per-user rate limiting (keyed by authenticated userId) ───────────────────
// Applied AFTER body parsing so the JWT can be decoded
// Falls back to IP for unauthenticated requests
const jwt = require('jsonwebtoken');

function getUserKey(req) {
  try {
    const authHeader = req.headers.authorization;
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const decoded = jwt.decode(authHeader.split(' ')[1]);
      if (decoded && decoded.id) return `user_${decoded.id}`;
    }
  } catch (_) {}
  return req.ip;
}

// General API — 120 calls per minute per user
const perUserApiLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: process.env.NODE_ENV === 'test' ? 10000 : 120,
  keyGenerator: getUserKey,
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => req.path.startsWith('/api/auth'), // auth has its own limiter
  message: { success: false, message: 'Rate limit exceeded. Please slow down.' },
});

// Heavy write endpoints — 20 calls per minute per user
const perUserStrictLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: process.env.NODE_ENV === 'test' ? 10000 : 20,
  keyGenerator: getUserKey,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests on this endpoint. Please wait.' },
});

app.use('/api', perUserApiLimiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// NoSQL injection sanitization
app.use(mongoSanitize());

// Serve static uploads folder (for KYC and Profile photos)
app.use('/api/uploads', express.static(path.join(__dirname, '../../uploads')));
app.use('/uploads', express.static(path.join(__dirname, '../../uploads')));

// HTTP request logging
app.use(requestLogger);

// ── Database ─────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
  connectDB();
}

// ── MQTT ────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
  initializeMqtt();
  logger.info('MQTT client initialized');

  // ── Recover dispatch loops for orders stuck searching after a restart ─────────
  (async () => {
    try {
      const stuckOrders = await Order.find({ status: 'pending', dispatchStatus: 'searching' });
      for (const order of stuckOrders) {
        // Reset expiry to a short window so we don't flood immediately
        order.dispatchExpiresAt = new Date(Date.now() + 5000);
        await order.save();
        startDispatch(order._id);
      }
      if (stuckOrders.length > 0) {
        logger.warn(`Recovered ${stuckOrders.length} searching order(s)`);
      }
    } catch (err) {
      logger.error('Dispatch recovery error', { error: err.message });
    }
  })();
}

// ── Routes ───────────────────────────────────────────────────────────────────
app.use(routes);

// ── Error handler ────────────────────────────────────────────────────────────
if (process.env.SENTRY_DSN) {
  Sentry.setupExpressErrorHandler(app);
}
app.use(errorHandler);

// ── Start ─────────────────────────────────────────────────────────────────────
if (process.env.NODE_ENV !== 'test') {
  const PORT = process.env.PORT || 9001;
  server.listen(PORT, () => {
    logger.info(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`);
  });
}

// ── Unhandled rejection handler ──────────────────────────────────────────────
process.on('unhandledRejection', (reason, promise) => {
  logger.error('Unhandled promise rejection', { reason: reason?.message || reason });
  if (process.env.SENTRY_DSN) {
    Sentry.captureException(reason);
  }
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught exception', { error: error.message, stack: error.stack });
  if (process.env.SENTRY_DSN) {
    Sentry.captureException(error);
  }
  process.exit(1);
});

module.exports = { app, server };
