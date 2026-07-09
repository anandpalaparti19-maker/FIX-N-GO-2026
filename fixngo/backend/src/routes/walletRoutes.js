const express = require('express');
const { requestWithdrawal, getWithdrawalHistory } = require('../controllers/walletController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

router.post('/withdraw', protect, requestWithdrawal);
// AUDIT FIX §4.1: Add missing withdrawal history endpoint
router.get('/withdraw/history', protect, getWithdrawalHistory);

module.exports = router;
