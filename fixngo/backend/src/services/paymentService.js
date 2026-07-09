/**
 * Shared Payment Service
 * Centralizes wallet crediting + platform ledger recording.
 * Called by paymentController.confirmPayment after a successful Cashfree payment.
 */

const Order = require('../models/orderModel');
const User = require('../models/userModel');
const WalletTransaction = require('../models/walletTransactionModel');
const PlatformLedger = require('../models/platformLedgerModel');
const mongoose = require('mongoose');
const { emitNotification } = require('../utils/mqttService');
const { logger } = require('../utils/logger');

/**
 * Credits the technician's wallet, records a WalletTransaction,
 * and writes the PlatformLedger commission split — all in a single
 * Mongo transaction so either everything succeeds or nothing does.
 *
 * @param {string} orderId - The Order._id to process
 * @returns {Object} { success: boolean, message: string }
 */
const creditTechnicianWallet = async (orderId) => {
  const order = await Order.findById(orderId);
  if (!order) {
    return { success: false, message: 'Order not found' };
  }

  // Idempotency guard — don't double-credit
  const existingCredit = await WalletTransaction.findOne({
    bookingId: order._id,
    type: 'credit',
  });
  if (existingCredit) {
    logger.info(`Wallet already credited for order ${orderId}, skipping`);
    return { success: true, message: 'Already credited' };
  }

  const session = await mongoose.startSession();
  session.startTransaction();

  try {
    // 1. Create wallet credit transaction
    await WalletTransaction.create(
      [
        {
          technicianId: order.technicianUser,
          bookingId: order._id,
          type: 'credit',
          amount: order.technicianEarning,
          description: `Earnings for order ${order._id}`,
        },
      ],
      { session }
    );

    // 2. Update technician's wallet balance and total earnings
    await User.findByIdAndUpdate(
      order.technicianUser,
      {
        $inc: {
          'technicianMeta.walletBalance': order.technicianEarning,
          'technicianMeta.totalEarnings': order.technicianEarning,
        },
      },
      { session }
    );

    // 3. Record platform commission split
    await PlatformLedger.create(
      [
        {
          bookingId: order._id,
          customerFee: order.customerFee,
          technicianCommission: order.technicianCommission,
          totalRevenue: order.customerFee + order.technicianCommission,
        },
      ],
      { session }
    );

    await session.commitTransaction();
    session.endSession();

    // 4. Notify technician via MQTT
    if (order.technicianUser) {
      emitNotification(order.technicianUser.toString(), {
        type: 'wallet_credited',
        title: 'Payment Received!',
        message: `₹${order.technicianEarning} has been credited to your wallet for order ${order._id}.`,
        amount: order.technicianEarning,
      });
    }

    return { success: true, message: 'Wallet credited successfully' };
  } catch (err) {
    await session.abortTransaction();
    session.endSession();
    logger.error('creditTechnicianWallet transaction failed', err);
    return { success: false, message: err.message };
  }
};

module.exports = { creditTechnicianWallet };
