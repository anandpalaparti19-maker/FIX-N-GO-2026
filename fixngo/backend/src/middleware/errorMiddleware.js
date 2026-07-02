const { logger } = require('../utils/logger');

const errorHandler = (err, req, res, next) => {
  // Determine if this is an operational error (expected) vs programmer error (bug)
  const isOperational = err.isOperational || err.statusCode != null;
  const statusCode = err.statusCode || res.statusCode === 200 ? 500 : res.statusCode;

  // Log with full context
  const logData = {
    error: err.message,
    statusCode,
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userId: req.user?._id?.toString(),
    isOperational,
  };

  if (!isOperational) {
    // Programmer errors get full stack traces
    logData.stack = err.stack;
    logger.error('Unhandled server error', logData);
  } else {
    logger.warn('Operational error', logData);
  }

  // CORS errors
  if (err.message && err.message.startsWith('CORS blocked')) {
    return res.status(403).json({
      success: false,
      message: 'Origin not allowed by CORS policy',
    });
  }

  // Mongoose validation errors
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map((e) => e.message);
    return res.status(400).json({
      success: false,
      message: 'Validation error',
      errors: messages,
    });
  }

  // Mongoose cast errors (invalid ObjectId)
  if (err.name === 'CastError') {
    return res.status(400).json({
      success: false,
      message: `Invalid ${err.path}: ${err.value}`,
    });
  }

  // MongoDB duplicate key errors
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return res.status(409).json({
      success: false,
      message: `Duplicate value for ${field}`,
    });
  }

  res.status(statusCode).json({
    success: false,
    message: process.env.NODE_ENV === 'production' && !isOperational
      ? 'Internal server error'
      : err.message,
    ...(process.env.NODE_ENV !== 'production' && { stack: err.stack }),
  });
};

module.exports = { errorHandler };
