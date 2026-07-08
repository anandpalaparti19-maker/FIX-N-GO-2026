const Technician = require('../models/technicianModel');
const Withdrawal = require('../models/withdrawalModel');
const WalletTransaction = require('../models/walletTransactionModel');
const mongoose = require('mongoose');
const cashfreePayout = require('../utils/cashfreePayout');

const PAYOUTS_ENABLED = process.env.CASHFREE_PAYOUTS_ENABLED === 'true' || process.env.RAZORPAY_PAYOUTS_ENABLED === 'true';

/**
 * Reverse a withdrawal debit when the downstream payout gateway fails.
 */
const reverseWithdrawal = async (withdrawalDoc, userId, amount, reason) => {
  const session = await mongoose.startSession();
  session.startTransaction();
  try {
    withdrawalDoc.status = 'failed';
    withdrawalDoc.notes = reason;
    await withdrawalDoc.save({ session });

    await WalletTransaction.create([{
      technicianId: userId,
      type: 'credit',
      amount: amount,
      description: `Withdrawal reversal: ${reason}`,
      referenceId: withdrawalDoc._id.toString(),
      status: 'success'
    }], { session });

    await Technician.findByIdAndUpdate(
      userId,
      { $inc: { 'technicianMeta.walletBalance': amount } },
      { session }
    );

    await session.commitTransaction();
  } finally {
    session.endSession();
  }
};

/**
 * Submit the withdrawal to Cashfree Payouts.
 * On gateway failure the debit is reversed.
 */
const submitPayout = async (withdrawalDoc, user, amount) => {
  if (!PAYOUTS_ENABLED) {
    return { skipped: true };
  }

  const bankDetails = user.technicianMeta.bankDetails;
  try {
    const token = await cashfreePayout.authorize();
    const beneId = await cashfreePayout.addBeneficiary(token, user, bankDetails);
    
    // Use the withdrawal document ID as the unique transfer ID
    const transferId = withdrawalDoc._id.toString();

    const payoutResult = await cashfreePayout.requestTransfer(token, beneId, amount, transferId);

    if (!payoutResult.success) {
       throw new Error(payoutResult.error);
    }

    withdrawalDoc.status = 'processing';
    withdrawalDoc.payoutGatewayId = payoutResult.referenceId || transferId;
    await withdrawalDoc.save();

    return { success: true, payoutId: withdrawalDoc.payoutGatewayId };
  } catch (err) {
    await reverseWithdrawal(
      withdrawalDoc,
      user._id,
      amount,
      `Payout gateway error: ${err.message || 'Unknown error'}`
    );
    return { success: false, error: err.message || 'Payout gateway error' };
  }
};

const requestWithdrawal = async (req, res, next) => {
  try {
    const { amount } = req.body;
    const parsedAmount = Number(amount);

    if (isNaN(parsedAmount) || parsedAmount < 500) {
      return res.status(400).json({ success: false, message: 'Minimum withdrawal amount is ₹500' });
    }

    if (req.user.role !== 'technician') {
      return res.status(403).json({ success: false, message: 'Only technicians can withdraw funds' });
    }

    const user = await Technician.findById(req.user._id);
    const techMeta = user.technicianMeta;

    // Check KYC & Bank
    if (techMeta.verification.status !== 'verified') {
      return res.status(400).json({ success: false, message: 'KYC not verified. Cannot withdraw.' });
    }
    if (!techMeta.bankDetails || !techMeta.bankDetails.accountNumber) {
      return res.status(400).json({ success: false, message: 'No bank details linked.' });
    }

    // Check balance optimistically
    if (techMeta.walletBalance < parsedAmount) {
      return res.status(400).json({ success: false, message: 'Insufficient wallet balance' });
    }

    // Atomic Debit Transaction
    const session = await mongoose.startSession();
    session.startTransaction();
    let withdrawal;

    try {
      const updatedUser = await Technician.findOneAndUpdate(
        { _id: user._id, 'technicianMeta.walletBalance': { $gte: parsedAmount } },
        { $inc: { 'technicianMeta.walletBalance': -parsedAmount } },
        { session, new: true }
      );

      if (!updatedUser) {
        throw new Error('Insufficient balance or concurrent transaction conflict');
      }

      withdrawal = await Withdrawal.create([{
        technician: user._id,
        amount: parsedAmount,
        bankAccount: techMeta.bankDetails.accountNumber,
        status: 'pending'
      }], { session });

      await WalletTransaction.create([{
        technicianId: user._id,
        type: 'debit',
        amount: parsedAmount,
        description: `Withdrawal request`,
        referenceId: withdrawal[0]._id.toString()
      }], { session });

      await session.commitTransaction();
      session.endSession();
    } catch (err) {
      await session.abortTransaction();
      session.endSession();
      if (err.message.includes('Insufficient balance')) {
        return res.status(400).json({ success: false, message: 'Insufficient wallet balance. Please try again.' });
      }
      throw err;
    }

    const payoutResult = await submitPayout(withdrawal[0], user, amount);

    if (payoutResult.success === false) {
      return res.status(502).json({
        success: false,
        message: 'Withdrawal failed at payout gateway. Amount has been reversed to wallet.',
        error: payoutResult.error,
        data: withdrawal[0]
      });
    }

    res.json({
      success: true,
      message: PAYOUTS_ENABLED
        ? 'Withdrawal submitted to payout gateway'
        : 'Withdrawal requested successfully (payouts disabled; admin will process manually)',
      data: withdrawal[0]
    });

  } catch (error) {
    next(error);
  }
};

module.exports = { requestWithdrawal };
