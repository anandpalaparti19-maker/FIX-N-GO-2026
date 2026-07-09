
const axios = require('axios');
const Payment = require('../models/paymentModel');
const WalletTransaction = require('../models/walletTransactionModel');
const Order = require('../models/orderModel');
const User = require('../models/userModel');
const { logger } = require('../utils/logger');
const { creditTechnicianWallet } = require('../services/paymentService');

const getCashfreeUrl = (endpoint) => {
  const isProd = process.env.CASHFREE_ENVIRONMENT === 'production';
  const baseUrl = isProd ? 'https://api.cashfree.com/pg' : 'https://sandbox.cashfree.com/pg';
  return `${baseUrl}${endpoint}`;
};

const getCashfreeHeaders = () => {
  return {
    'x-client-id': process.env.CASHFREE_APP_ID,
    'x-client-secret': process.env.CASHFREE_SECRET_KEY,
    'x-api-version': '2023-08-01',
    'Content-Type': 'application/json',
    'Accept': 'application/json'
  };
};

// Create Cashfree Order
const createPaymentIntent = async (req, res, next) => {
  try {
    const { orderId, amount } = req.body;

    if (!orderId || !amount || amount <= 0) {
      return res.status(400).json({ success: false, message: 'Invalid order ID or amount' });
    }

    const order = await Order.findById(orderId);
    if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    const requestPayload = {
      "order_amount": amount,
      "order_currency": "INR",
      "order_id": `order_${orderId}_${Date.now()}`,
      "customer_details": {
        "customer_id": req.user._id.toString(),
        "customer_phone": req.user.phone || "9999999999",
      }
    };

    const response = await axios.post(getCashfreeUrl('/orders'), requestPayload, { headers: getCashfreeHeaders() });
    
    const cashfreeOrderId = response.data.order_id;
    const paymentSessionId = response.data.payment_session_id;

    const payment = await Payment.create({
      orderId: order._id,
      customerId: req.user._id,
      cashfreeOrderId: cashfreeOrderId,
      amount: amount,
      currency: 'inr',
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      message: 'Payment intent created',
      data: {
        paymentSessionId: paymentSessionId,
        cashfreeOrderId: cashfreeOrderId,
        paymentId: payment._id,
        amount: amount,
        orderId: order._id,
      },
    });
  } catch (error) {
    logger.error('Payment intent error:', error?.response?.data || error);
    next(error);
  }
};

// Confirm Cashfree Payment — now includes wallet/ledger crediting
const confirmPayment = async (req, res, next) => {
  try {
    const { cashfreeOrderId, paymentId, orderId } = req.body;
    if (!cashfreeOrderId || !paymentId) {
      return res.status(400).json({ success: false, message: 'Missing parameters' });
    }

    const payment = await Payment.findById(paymentId);
    if (!payment) return res.status(404).json({ success: false, message: 'Payment record not found' });

    // SECURITY: Verify cashfreeOrderId strictly matches what we generated
    if (payment.cashfreeOrderId !== cashfreeOrderId) {
      return res.status(400).json({ success: false, message: 'Invalid payment order ID' });
    }

    const response = await axios.get(getCashfreeUrl(`/orders/${cashfreeOrderId}/payments`), { headers: getCashfreeHeaders() });
    const payments = response.data;
    
    // Check if any payment was successful
    const successfulPayment = Array.isArray(payments) ? payments.find(p => p.payment_status === "SUCCESS") : null;
    
    if (successfulPayment) {
      const order = await Order.findById(orderId || payment.orderId);
      
      // SECURITY: Verify payment amount matches the order total
      if (order && Number(successfulPayment.payment_amount) !== Number(order.customerTotal)) {
        return res.status(400).json({ success: false, message: 'Payment amount mismatch' });
      }

      payment.status = 'completed';
      await payment.save();

      if (order) {
        order.paymentStatus = 'captured';
        order.cashfreeOrderId = cashfreeOrderId;
        await order.save();

        // AUDIT FIX §3.1: Credit technician wallet + platform ledger
        const creditResult = await creditTechnicianWallet(order._id);
        if (!creditResult.success && creditResult.message !== 'Already credited') {
          logger.error(`Wallet crediting failed for order ${order._id}: ${creditResult.message}`);
          // Payment is captured but wallet credit failed — log for reconciliation
          // Do NOT fail the response; the payment is already captured at the gateway
        }
      }

      return res.status(200).json({ success: true, message: 'Payment successful', payment });
    } else {
      payment.status = 'failed';
      await payment.save();
      return res.status(400).json({ success: false, message: 'Payment not successful' });
    }
  } catch (error) {
    logger.error('Confirm payment error:', error?.response?.data || error);
    next(error);
  }
};

const getPaymentHistory = async (req, res, next) => {
  try {
    const payments = await Payment.find({ customerId: req.user._id }).populate('orderId', 'serviceType createdAt').sort({ createdAt: -1 });
    res.status(200).json({ success: true, data: payments });
  } catch (error) { next(error); }
};

// AUDIT FIX: Read from technicianMeta.totalEarnings (correct field path)
const getTechnicianEarnings = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    const techMeta = user?.technicianMeta || {};
    res.status(200).json({
      success: true,
      data: {
        totalEarnings: techMeta.totalEarnings || 0,
        pendingEarnings: techMeta.pendingEarnings || 0,
        walletBalance: techMeta.walletBalance || 0,
      },
    });
  } catch (error) { next(error); }
};

// AUDIT FIX: Real implementation using WalletTransaction aggregation
const getMonthlyEarnings = async (req, res, next) => {
  try {
    const monthlyData = await WalletTransaction.aggregate([
      {
        $match: {
          technicianId: req.user._id,
          type: 'credit',
          status: { $ne: 'failed' },
        },
      },
      {
        $group: {
          _id: {
            year: { $year: '$createdAt' },
            month: { $month: '$createdAt' },
          },
          totalEarnings: { $sum: '$amount' },
          count: { $sum: 1 },
        },
      },
      { $sort: { '_id.year': -1, '_id.month': -1 } },
      { $limit: 12 },
    ]);

    const formatted = monthlyData.map((item) => ({
      year: item._id.year,
      month: item._id.month,
      totalEarnings: item.totalEarnings,
      jobCount: item.count,
    }));

    res.status(200).json({ success: true, data: formatted });
  } catch (error) { next(error); }
};

// AUDIT FIX M-8: Dedicated cash-on-delivery confirmation endpoint
// Bypasses Cashfree ID check — credits technician wallet directly for COD orders
const confirmCashPayment = async (req, res, next) => {
  try {
    const { orderId } = req.body;
    if (!orderId) {
      return res.status(400).json({ success: false, message: 'Order ID is required' });
    }

    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({ success: false, message: 'Order not found' });
    }

    // Only the customer who owns the order can confirm cash payment
    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    // Order must be completed before payment can be confirmed
    if (order.status !== 'completed') {
      return res.status(400).json({ success: false, message: 'Order must be completed before confirming payment' });
    }

    // Idempotency: don't double-process
    if (order.paymentStatus === 'captured') {
      return res.status(200).json({ success: true, message: 'Payment already confirmed' });
    }

    // Create a payment record for the cash payment
    const payment = await Payment.create({
      orderId: order._id,
      customerId: req.user._id,
      cashfreeOrderId: `cash_${order._id}_${Date.now()}`,
      amount: order.customerTotal,
      currency: 'inr',
      status: 'completed',
    });

    // Mark order as paid
    order.paymentStatus = 'captured';
    order.paymentMethod = 'cash';
    await order.save();

    // Credit technician wallet + platform ledger
    const creditResult = await creditTechnicianWallet(order._id);
    if (!creditResult.success && creditResult.message !== 'Already credited') {
      logger.error(`Cash payment wallet crediting failed for order ${order._id}: ${creditResult.message}`);
    }

    res.status(200).json({
      success: true,
      message: 'Cash payment confirmed',
      data: { payment, orderId: order._id },
    });
  } catch (error) {
    logger.error('Confirm cash payment error:', error);
    next(error);
  }
};

module.exports = {
  createPaymentIntent,
  confirmPayment,
  confirmCashPayment,
  getPaymentHistory,
  getTechnicianEarnings,
  getMonthlyEarnings,
};
