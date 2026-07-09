const express = require('express');
const {
  createPaymentIntent,
  confirmPayment,
  confirmCashPayment,
  getPaymentHistory,
  getTechnicianEarnings,
  getMonthlyEarnings,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');

const router = express.Router();

// Payment endpoints (Cashfree)
router.post('/create-intent', protect, createPaymentIntent);
router.post('/confirm', protect, confirmPayment);
// AUDIT FIX M-8: Cash-on-delivery confirmation — bypasses Cashfree ID check
router.post('/confirm-cash', protect, confirmCashPayment);
router.get('/history', protect, getPaymentHistory);

// Technician earnings endpoints
router.get('/earnings', protect, authorize('technician'), getTechnicianEarnings);
router.get('/earnings/monthly', protect, authorize('technician'), getMonthlyEarnings);

module.exports = router;
