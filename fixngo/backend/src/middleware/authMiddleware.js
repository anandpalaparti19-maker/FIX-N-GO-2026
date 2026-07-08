const jwt = require('jsonwebtoken');
const Customer = require('../models/customerModel');
const Technician = require('../models/technicianModel');
const Admin = require('../models/adminModel');

const protect = async (req, res, next) => {
  let token = null;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({ message: 'Not authorized, token missing' });
  }

  if (!process.env.JWT_SECRET) {
    console.error('FATAL: JWT_SECRET environment variable is not set');
    return res.status(500).json({ message: 'Server misconfiguration' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role === 'customer') {
      req.user = await Customer.findById(decoded.id).select('-password');
    } else if (decoded.role === 'technician') {
      req.user = await Technician.findById(decoded.id).select('-password');
    } else if (decoded.role === 'admin') {
      req.user = await Admin.findById(decoded.id).select('-password');
    }

    if (!req.user) {
      return res.status(401).json({ message: 'Not authorized, user not found' });
    }
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Not authorized, token invalid' });
  }
};

module.exports = { protect };
