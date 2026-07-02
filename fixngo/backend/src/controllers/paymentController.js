const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY || 'sk_test_fake');
const Payment = require('../models/paymentModel');
const Withdrawal = require('../models/withdrawalModel');
const Order = require('../models/orderModel');
const User = require('../models/userModel');

// Create Stripe Payment Intent
const createPaymentIntent = async (req, res, next) => {
  try {
    const { orderId, amount } = req.body;

    if (!orderId || !amount) {
      return res.status(400).json({
        success: false,
        message: 'Order ID and amount are required',
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be greater than 0',
      });
    }

    // Verify order exists and belongs to customer
    const order = await Order.findById(orderId);
    if (!order) {
      return res.status(404).json({
        success: false,
        message: 'Order not found',
      });
    }

    if (order.user.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to pay for this order',
      });
    }

    // Convert to paise (Stripe uses smallest currency unit)
    const amountInPaise = Math.round(amount * 100);

    // Create payment intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountInPaise,
      currency: 'inr',
      metadata: {
        orderId: orderId,
        customerId: req.user._id.toString(),
      },
    });

    logger.info(`Payment intent created: ${paymentIntent.id}`);

    // Store payment in DB
    const payment = await Payment.create({
      orderId: orderId,
      customerId: req.user._id,
      stripePaymentIntentId: paymentIntent.id,
      amount: amount,
      currency: 'inr',
      status: 'pending',
    });

    res.status(201).json({
      success: true,
      message: 'Payment intent created',
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentId: payment._id,
        amount: amount,
        orderId: orderId,
      },
    });
  } catch (error) {
    logger.error('Payment intent error:', error);
    next(error);
  }
};

// Confirm payment
const confirmPayment = async (req, res, next) => {
  try {
    const { paymentIntentId, paymentId, orderId } = req.body;

    if (!paymentIntentId || !paymentId) {
      return res.status(400).json({
        success: false,
        message: 'Payment intent ID and payment ID are required',
      });
    }

    // Get payment from DB
    const payment = await Payment.findById(paymentId);
    if (!payment) {
      return res.status(404).json({
        success: false,
        message: 'Payment record not found',
      });
    }

    // Idempotency: if payment already completed, return success without re-processing
    if (payment.status === 'completed') {
      return res.json({
        success: true,
        message: 'Payment already confirmed',
        data: {
          paymentId: payment._id,
          status: payment.status,
          amount: payment.amount,
          orderId: payment.orderId,
        },
      });
    }

    // Verify payment belongs to user
    if (payment.customerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized',
      });
    }

    // Verify payment amount matches order total (prevent client-side tampering)
    const order = await Order.findById(payment.orderId);
    if (order && Math.abs(payment.amount - order.customerTotal) > 0.01) {
      logger.error(`Payment amount mismatch: payment=${payment.amount}, order=${order.customerTotal}`);
      return res.status(400).json({
        success: false,
        message: 'Payment amount does not match order total',
      });
    }

    let paymentSucceeded = false;
    
    if (paymentIntentId.startsWith('pi_test')) {
      // Mock mode for testing only — accept test payment intents
      if (process.env.NODE_ENV === 'production') {
        return res.status(400).json({
          success: false,
          message: 'Test payment intents are not allowed in production',
        });
      }
      paymentSucceeded = true;
      logger.info(`[MOCK] Payment intent ${paymentIntentId} accepted in test mode`);
    } else {
      // Get payment intent from Stripe — failures MUST propagate, never silently succeed
      const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
      paymentSucceeded = paymentIntent.status === 'succeeded';
    }

    if (!paymentSucceeded) {
      return res.status(400).json({
        success: false,
        message: 'Payment was not successful',
      });
    }

    // Update payment status
    payment.status = 'completed';
    payment.paymentIntentId = paymentIntentId;
    await payment.save();

    // Update order
    if (order) {
      order.paymentStatus = 'collected';
      order.stripePaymentIntentId = paymentIntentId;
      order.paymentMethod = 'card';
      const { technicianCut } = require('../utils/orderHelpers');
      const earning = technicianCut(order.total);
      order.technicianEarning = earning;
      await order.save();

      // Calculate and add earnings to technician
      if (order.technicianUser) {
        await User.findByIdAndUpdate(
          order.technicianUser,
          {
            $inc: {
              'technicianMeta.walletBalance': earning,
              'technicianMeta.totalEarnings': earning,
            },
          },
          { new: true }
        );
      }
    }

    res.json({
      success: true,
      message: 'Payment confirmed successfully',
      data: {
        paymentId: payment._id,
        status: payment.status,
        amount: payment.amount,
        orderId: payment.orderId,
      },
    });
  } catch (error) {
    logger.error('Confirm payment error:', error);
    next(error);
  }
};

// Get payment history
const getPaymentHistory = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = 10;
    const skip = (page - 1) * limit;

    const payments = await Payment.find({ customerId: req.user._id })
      .populate('orderId', 'brand model issues total')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Payment.countDocuments({ customerId: req.user._id });

    res.json({
      success: true,
      count: payments.length,
      total,
      pages: Math.ceil(total / limit),
      page,
      data: payments.map((p) => ({
        _id: p._id,
        orderId: p.orderId?._id,
        orderDetails: p.orderId,
        amount: p.amount,
        status: p.status,
        paymentMethod: p.paymentMethod,
        createdAt: p.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};

// Get technician earnings
const getTechnicianEarnings = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can access this endpoint',
      });
    }

    const completedOrders = await Order.find({
      technicianUser: req.user._id,
      status: 'completed',
    });

    const totalEarned = completedOrders.reduce((sum, order) => sum + (order.technicianEarning || 0), 0);

    const user = await User.findById(req.user._id);

    res.json({
      success: true,
      data: {
        totalEarned: totalEarned,
        pendingEarnings: user?.technicianMeta?.pendingEarnings || 0,
        walletBalance: user?.technicianMeta?.walletBalance || 0,
        completedOrders: completedOrders.length,
      },
    });
  } catch (error) {
    next(error);
  }
};

// Get monthly earnings breakdown
const getMonthlyEarnings = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can access this endpoint',
      });
    }

    const completedOrders = await Order.find({
      technicianUser: req.user._id,
      status: 'completed',
    })
      .select('completedAt technicianEarning')
      .sort({ completedAt: -1 });

    // Group by month
    const monthlyData = {};

    completedOrders.forEach((order) => {
      if (!order.completedAt) return;

      const date = new Date(order.completedAt);
      const monthKey = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;

      if (!monthlyData[monthKey]) {
        monthlyData[monthKey] = { month: monthKey, earning: 0, orders: 0 };
      }

      monthlyData[monthKey].earning += order.technicianEarning || 0;
      monthlyData[monthKey].orders += 1;
    });

    const monthlyBreakdown = Object.values(monthlyData).sort((a, b) =>
      b.month.localeCompare(a.month)
    );

    res.json({
      success: true,
      count: monthlyBreakdown.length,
      data: monthlyBreakdown,
    });
  } catch (error) {
    next(error);
  }
};

// Request withdrawal
const requestWithdrawal = async (req, res, next) => {
  try {
    if (req.user.role !== 'technician') {
      return res.status(403).json({
        success: false,
        message: 'Only technicians can request withdrawals',
      });
    }

    const { amount, bankAccount } = req.body;

    if (!amount || !bankAccount) {
      return res.status(400).json({
        success: false,
        message: 'Amount and bank account details are required',
      });
    }

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Amount must be greater than 0',
      });
    }

    const user = await User.findById(req.user._id);

    if (user.technicianMeta.walletBalance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient wallet balance',
      });
    }

    // Create withdrawal record
    const withdrawal = await Withdrawal.create({
      technician: req.user._id,
      amount,
      bankAccount,
      status: 'pending',
    });

    // Deduct from wallet balance immediately (hold)
    user.technicianMeta.walletBalance -= amount;
    await user.save();

    res.status(201).json({
      success: true,
      message: 'Withdrawal request created successfully',
      data: withdrawal,
    });
  } catch (error) {
    logger.error('Request withdrawal error:', error);
    next(error);
  }
};

// Get withdrawal history
const getWithdrawalHistory = async (req, res, next) => {
  try {
    const history = await Withdrawal.find({ technician: req.user._id }).sort({ createdAt: -1 });
    res.json({
      success: true,
      data: history,
    });
  } catch (error) {
    next(error);
  }
};

// Stripe Webhook handler
const handleStripeWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event;

  if (endpointSecret && sig) {
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, endpointSecret);
    } catch (err) {
      logger.error('Webhook signature verification failed:', err.message);
      return res.status(400).json({ error: `Webhook Error: ${err.message}` });
    }
  } else {
    // In dev/test mode without webhook secret, parse the body directly
    try {
      event = typeof req.body === 'string' ? JSON.parse(req.body) : req.body;
    } catch (err) {
      return res.status(400).json({ error: 'Invalid webhook payload' });
    }
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded': {
      const paymentIntent = event.data.object;
      logger.info(`[Webhook] PaymentIntent succeeded: ${paymentIntent.id}`);

      // Find and update payment record
      const payment = await Payment.findOne({ stripePaymentIntentId: paymentIntent.id });
      if (payment && payment.status !== 'completed') {
        payment.status = 'completed';
        await payment.save();

        // Update associated order
        const order = await Order.findById(payment.orderId);
        if (order) {
          order.paymentStatus = 'collected';
          order.stripePaymentIntentId = paymentIntent.id;
          order.paymentMethod = 'card';
          const { technicianCut } = require('../utils/orderHelpers');
const { logger } = require('../utils/logger');
          order.technicianEarning = technicianCut(order.total);
          await order.save();

          if (order.technicianUser) {
            await User.findByIdAndUpdate(order.technicianUser, {
              $inc: {
                'technicianMeta.walletBalance': order.technicianEarning,
                'technicianMeta.totalEarnings': order.technicianEarning,
              },
            });
          }
        }
      }
      break;
    }
    case 'payment_intent.payment_failed': {
      const failedIntent = event.data.object;
      logger.info(`[Webhook] PaymentIntent failed: ${failedIntent.id}`);

      const failedPayment = await Payment.findOne({ stripePaymentIntentId: failedIntent.id });
      if (failedPayment) {
        failedPayment.status = 'failed';
        await failedPayment.save();
      }
      break;
    }
    default:
      logger.info(`[Webhook] Unhandled event type: ${event.type}`);
  }

  res.json({ received: true });
};

// Admin: Get all withdrawals
const getAllWithdrawals = async (req, res, next) => {
  try {
    const withdrawals = await Withdrawal.find()
      .populate('technician', 'name email phone technicianMeta')
      .sort({ createdAt: -1 });
    res.json({ success: true, data: withdrawals });
  } catch (error) {
    next(error);
  }
};

// Admin: Approve withdrawal
const approveWithdrawal = async (req, res, next) => {
  try {
    const withdrawal = await Withdrawal.findById(req.params.id);
    if (!withdrawal) {
      return res.status(404).json({ success: false, message: 'Withdrawal not found' });
    }
    if (withdrawal.status !== 'pending') {
      return res.status(400).json({ success: false, message: 'Withdrawal is not pending' });
    }

    withdrawal.status = 'approved';
    withdrawal.processedAt = new Date();
    await withdrawal.save();

    res.json({ success: true, message: 'Withdrawal approved', data: withdrawal });
  } catch (error) {
    next(error);
  }
};

// Admin: Reject withdrawal
const rejectWithdrawal = async (req, res, next) => {
  try {
    const withdrawal = await Withdrawal.findById(req.params.id);
    if (!withdrawal) {
      return res.status(404).json({ success: false, message: 'Withdrawal not found' });
    }
    if (withdrawal.status !== 'pending') {
      return res.status(400).json({ success: false, message: 'Withdrawal is not pending' });
    }

    // Refund the held amount back to wallet
    await User.findByIdAndUpdate(withdrawal.technician, {
      $inc: { 'technicianMeta.walletBalance': withdrawal.amount },
    });

    withdrawal.status = 'rejected';
    withdrawal.processedAt = new Date();
    await withdrawal.save();

    res.json({ success: true, message: 'Withdrawal rejected, funds returned', data: withdrawal });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createPaymentIntent,
  confirmPayment,
  getPaymentHistory,
  getTechnicianEarnings,
  getMonthlyEarnings,
  requestWithdrawal,
  getWithdrawalHistory,
  handleStripeWebhook,
  getAllWithdrawals,
  approveWithdrawal,
  rejectWithdrawal,
};
