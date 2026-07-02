/**
 * Structured logging with Winston.
 * - Console transport: colorized, human-readable (dev)
 * - File transport: JSON, daily rotation (prod)
 * - Request context via AsyncLocalStorage
 */
const { createLogger, format, transports } = require('winston');
const path = require('path');

const isProduction = process.env.NODE_ENV === 'production';

// ── Custom format: add request context ──────────────────────────
const contextFormat = format((info) => {
  // Attach requestId and userId if available from AsyncLocalStorage
  if (global.__requestContext) {
    const ctx = global.__requestContext.getStore();
    if (ctx) {
      info.requestId = ctx.requestId;
      info.userId = ctx.userId;
    }
  }
  return info;
});

// ── Create logger ───────────────────────────────────────────────
const logger = createLogger({
  level: isProduction ? 'info' : 'debug',
  format: format.combine(
    contextFormat(),
    format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss.SSS' }),
    format.errors({ stack: true })
  ),
  defaultMeta: { service: 'fixngo-backend' },
  transports: [],
});

// Console transport — always active
if (isProduction) {
  logger.add(
    new transports.Console({
      format: format.combine(format.json()),
    })
  );
} else {
  logger.add(
    new transports.Console({
      format: format.combine(
        format.colorize(),
        format.printf(({ level, message, timestamp, requestId, userId, ...meta }) => {
          const ctx = [requestId && `req:${requestId}`, userId && `user:${userId}`]
            .filter(Boolean)
            .join(' ');
          const ctxStr = ctx ? ` [${ctx}]` : '';
          const metaStr = Object.keys(meta).length > 1 ? ` ${JSON.stringify(meta)}` : '';
          return `${timestamp} ${level}:${ctxStr} ${message}${metaStr}`;
        })
      ),
    })
  );
}

// File transport — production only, JSON format
if (isProduction) {
  try {
    const DailyRotateFile = require('winston-daily-rotate-file');
    logger.add(
      new DailyRotateFile({
        filename: path.join(__dirname, '../../logs/app-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        maxSize: '20m',
        maxFiles: '14d',
        format: format.combine(format.json()),
      })
    );
    logger.add(
      new DailyRotateFile({
        filename: path.join(__dirname, '../../logs/error-%DATE%.log'),
        datePattern: 'YYYY-MM-DD',
        level: 'error',
        maxSize: '20m',
        maxFiles: '30d',
        format: format.combine(format.json()),
      })
    );
  } catch (err) {
    // winston-daily-rotate-file is optional
    logger.add(
      new transports.File({
        filename: path.join(__dirname, '../../logs/app.log'),
        format: format.combine(format.json()),
      })
    );
    logger.add(
      new transports.File({
        filename: path.join(__dirname, '../../logs/error.log'),
        level: 'error',
        format: format.combine(format.json()),
      })
    );
  }
}

// ── HTTP request logging middleware ──────────────────────────────
const { AsyncLocalStorage } = require('node:async_hooks');
const asyncLocalStorage = new AsyncLocalStorage();
global.__requestContext = asyncLocalStorage;

let requestCounter = 0;
const requestLogger = (req, res, next) => {
  const requestId = `${Date.now()}-${++requestCounter}`;
  const store = { requestId, userId: req.user?._id?.toString() };

  asyncLocalStorage.run(store, () => {
    const start = Date.now();
    res.on('finish', () => {
      const duration = Date.now() - start;
      const logData = {
        method: req.method,
        url: req.originalUrl,
        status: res.statusCode,
        duration: `${duration}ms`,
        ip: req.ip,
      };

      if (res.statusCode >= 500) {
        logger.error('Request completed with server error', logData);
      } else if (res.statusCode >= 400) {
        logger.warn('Request completed with client error', logData);
      } else {
        logger.http('Request completed', logData);
      }
    });
    next();
  });
};

// ── Update userId in context after auth middleware runs ──────────
const updateRequestContext = (req, res, next) => {
  const store = asyncLocalStorage.getStore();
  if (store && req.user?._id) {
    store.userId = req.user._id.toString();
  }
  next();
};

module.exports = { logger, requestLogger, updateRequestContext };
