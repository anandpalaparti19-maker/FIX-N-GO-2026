const express = require('express');
const {
  getOrders,
  createOrder,
  getOrderById,
  updateOrderStatus,
} = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Customer routes
router.route('/').get(protect, getOrders).post(protect, createOrder);
router.route('/:id').get(protect, getOrderById);
router.put('/:id/status', protect, updateOrderStatus);

module.exports = router;

