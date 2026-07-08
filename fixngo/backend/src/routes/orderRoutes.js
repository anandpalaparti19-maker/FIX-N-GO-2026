const express = require('express');
const {
  getOrders,
  createOrder,
  getOrderById,
  updateOrderStatus,
  acceptOrder,
  rejectOrder,
  completeOrder,
  getAvailableOrders,
  getTechnicianOrders,
} = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// Technician Routes
router.get('/available', protect, getAvailableOrders);
router.get('/technician', protect, getTechnicianOrders);
router.patch('/:id/accept', protect, acceptOrder);
router.patch('/:id/reject', protect, rejectOrder);
router.post('/:id/complete', protect, completeOrder);

// Customer/General Routes
router.patch('/:id/cancel', protect, (req, res, next) => {
  req.body.status = 'cancelled';
  req.body.note = 'Cancelled by user';
  updateOrderStatus(req, res, next);
});
router.route('/').get(protect, getOrders).post(protect, createOrder);
router.route('/:id').get(protect, getOrderById).patch(protect, updateOrderStatus);
router.put('/:id/status', protect, updateOrderStatus);

module.exports = router;

