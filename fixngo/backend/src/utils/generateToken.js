const jwt = require('jsonwebtoken');

const generateToken = (id, role) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET environment variable is not set');
  }
  return jwt.sign({ id, role }, process.env.JWT_SECRET, {
    expiresIn: '15m', // Short-lived access token — use refresh token rotation for session continuity
  });
};

module.exports = generateToken;
