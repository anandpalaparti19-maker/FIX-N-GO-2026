const express = require('express');
const {
  createPaymentIntent,
  confirmPayment,
  getPaymentHistory,
  getTechnicianEarnings,
  getMonthlyEarnings,
  handleStripeWebhook,
} = require('../controllers/paymentController');
const { protect } = require('../middleware/authMiddleware');
const { authorize } = require('../middleware/roleMiddleware');
const { adminOnly } = require('../middleware/adminMiddleware');

const router = express.Router();

// Stripe Webhook — must use raw body, placed BEFORE json parser
router.post('/webhook', express.raw({ type: 'application/json' }), handleStripeWebhook);

// Payment endpoints
router.post('/create-intent', protect, createPaymentIntent);
router.post('/confirm', protect, confirmPayment);
router.get('/history', protect, getPaymentHistory);

// Technician earnings endpoints
router.get('/earnings', protect, authorize('technician'), getTechnicianEarnings);
router.get('/earnings/monthly', protect, authorize('technician'), getMonthlyEarnings);

module.exports = router;
