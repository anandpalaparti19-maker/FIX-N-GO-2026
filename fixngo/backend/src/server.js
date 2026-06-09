require('dotenv').config();

// ── Startup environment validation ──────────────────────────────────────────
const REQUIRED_ENV = ['MONGO_URI', 'JWT_SECRET', 'PORT'];
const missing = REQUIRED_ENV.filter((k) => !process.env[k]);
if (missing.length > 0) {
  console.error(`FATAL: Missing required environment variables: ${missing.join(', ')}`);
  process.exit(1);
}

const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const mongoSanitize = require('express-mongo-sanitize');
const colors = require('colors');
const http = require('http');
const connectDB = require('./config/db');
const routes = require('./routes');
const { errorHandler } = require('./middleware/errorMiddleware');
const { initializeSocket } = require('./utils/socketService');

const app = express();
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
      // Allow server-to-server (no origin) in dev only
      if (!origin && process.env.NODE_ENV !== 'production') return callback(null, true);
      if (allowedOrigins.includes(origin)) return callback(null, true);
      callback(new Error(`CORS blocked: ${origin}`));
    },
    credentials: true,
  })
);

// Rate limiting — global
app.use(
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 200,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests, please try again later.' },
  })
);

// Stricter rate limit on auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  message: { success: false, message: 'Too many auth attempts, try again in 15 minutes.' },
});
app.use('/api/auth', authLimiter);

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// NoSQL injection sanitization
app.use(mongoSanitize());

// ── Database ─────────────────────────────────────────────────────────────────
connectDB();

// ── Socket.io ────────────────────────────────────────────────────────────────
initializeSocket(server);
console.log('Socket.io initialized'.cyan);

// ── Routes ───────────────────────────────────────────────────────────────────
app.use(routes);

// ── Error handler ────────────────────────────────────────────────────────────
app.use(errorHandler);

// ── Start ─────────────────────────────────────────────────────────────────────
const PORT = process.env.PORT || 5000;
server.listen(PORT, () => {
  console.log(`Server running in ${process.env.NODE_ENV} mode on port ${PORT}`.yellow.bold);
  console.log(`WebSocket server ready on port ${PORT}`.cyan);
});

module.exports = { app, server };
