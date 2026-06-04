const express = require('express');
const {
  createPaymentIntent,
  confirmPayment,
  getPaymentHistory,
  getTechnicianEarnings,
  getMonthlyEarnings,
  requestWithdrawal,
  getWithdrawalHistory,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

const router = express.Router();

// Payment endpoints
router.post('/create-intent', protect, createPaymentIntent);
router.post('/confirm', protect, confirmPayment);
router.get('/history', protect, getPaymentHistory);

// Technician earnings endpoints
router.get('/earnings', protect, authorize('technician'), getTechnicianEarnings);
router.get('/earnings/monthly', protect, authorize('technician'), getMonthlyEarnings);
router.post('/withdraw', protect, authorize('technician'), requestWithdrawal);
router.get('/withdraw/history', protect, authorize('technician'), getWithdrawalHistory);

module.exports = router;
