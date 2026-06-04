const express = require('express');
const {
  registerUser,
  loginUser,
  getProfile,
  updateProfile,
  forgotPassword,
  resetPassword,
  sendPhoneOtp,
  verifyPhoneOtp,
} = require('../controllers/authController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/register', registerUser);
router.post('/login', loginUser);
router.get('/profile', protect, getProfile);
router.patch('/profile', protect, updateProfile);

// Password reset endpoints
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);

// Phone OTP endpoints
router.post('/send-otp', sendPhoneOtp);
router.post('/verify-otp', verifyPhoneOtp);

module.exports = router;

