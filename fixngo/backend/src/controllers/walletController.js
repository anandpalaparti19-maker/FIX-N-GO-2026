const User = require('../models/userModel');
const Withdrawal = require('../models/withdrawalModel');
const WalletTransaction = require('../models/walletTransactionModel');
const mongoose = require('mongoose');
const razorpay = require('../utils/razorpay');

const PAYOUTS_ENABLED = process.env.RAZORPAY_PAYOUTS_ENABLED === 'true';
const RAZORPAYX_ACCOUNT_NUMBER = process.env.RAZORPAYX_ACCOUNT_NUMBER;

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

    await User.findByIdAndUpdate(
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
 * Create or reuse a RazorpayX contact + fund account for the technician.
 * Returns the fund account id.
 */
const getOrCreateFundAccount = async (user, bankDetails) => {
  const contact = await razorpay.contacts.create({
    name: user.name,
    email: user.email,
    contact: user.phone || '0000000000',
    type: 'vendor',
    reference_id: `tech_${user._id.toString()}`,
    notes: { source: 'Fix-N-Go withdrawal' }
  });

  const fundAccount = await razorpay.fundAccount.create({
    contact_id: contact.id,
    account_type: 'bank_account',
    bank_account: {
      name: bankDetails.accountName || user.name,
      ifsc: bankDetails.ifscCode,
      account_number: bankDetails.accountNumber
    }
  });

  return fundAccount.id;
};

/**
 * Submit the withdrawal to RazorpayX Payouts.
 * On gateway failure the debit is reversed.
 */
const submitPayout = async (withdrawalDoc, user, amount) => {
  if (!PAYOUTS_ENABLED || !RAZORPAYX_ACCOUNT_NUMBER) {
    return { skipped: true };
  }

  const bankDetails = user.technicianMeta.bankDetails;
  try {
    const fundAccountId = await getOrCreateFundAccount(user, bankDetails);

    const payout = await razorpay.payouts.create({
      account_number: RAZORPAYX_ACCOUNT_NUMBER,
      fund_account_id: fundAccountId,
      amount: Math.round(amount * 100), // paise
      currency: 'INR',
      mode: 'IMPS',
      purpose: 'payout',
      queue_if_low_balance: true,
      reference_id: withdrawalDoc._id.toString(),
      narration: 'Fix-N-Go Withdrawal'
    });

    withdrawalDoc.status = 'processing';
    withdrawalDoc.payoutGatewayId = payout.id;
    await withdrawalDoc.save();

    return { success: true, payoutId: payout.id };
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

    if (req.user.role !== 'technician') {
      return res.status(403).json({ success: false, message: 'Only technicians can withdraw funds' });
    }

    const user = await User.findById(req.user._id);
    const techMeta = user.technicianMeta;

    // Check KYC & Bank
    if (techMeta.verification.status !== 'verified') {
      return res.status(400).json({ success: false, message: 'KYC not verified. Cannot withdraw.' });
    }
    if (!techMeta.bankDetails || !techMeta.bankDetails.accountNumber) {
      return res.status(400).json({ success: false, message: 'No bank details linked.' });
    }

    // Check balance
    if (amount < 500) {
      return res.status(400).json({ success: false, message: 'Minimum withdrawal amount is ₹500' });
    }
    if (techMeta.walletBalance < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient wallet balance' });
    }

    // Optimistic Debit Transaction
    const session = await mongoose.startSession();
    session.startTransaction();
    let withdrawal;

    try {
      withdrawal = await Withdrawal.create([{
        technician: user._id,
        amount: amount,
        bankAccount: techMeta.bankDetails.accountNumber,
        status: 'pending'
      }], { session });

      await WalletTransaction.create([{
        technicianId: user._id,
        type: 'debit',
        amount: amount,
        description: `Withdrawal request`,
        referenceId: withdrawal[0]._id.toString()
      }], { session });

      await User.findByIdAndUpdate(
        user._id,
        { $inc: { 'technicianMeta.walletBalance': -amount } },
        { session }
      );

      await session.commitTransaction();
      session.endSession();
    } catch (err) {
      await session.abortTransaction();
      session.endSession();
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
