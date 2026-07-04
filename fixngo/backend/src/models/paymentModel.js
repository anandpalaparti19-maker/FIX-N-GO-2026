const mongoose = require('mongoose');

const paymentSchema = mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    cashfreeOrderId: { type: String, required: true },
    amount: { type: Number, required: true },
    currency: { type: String, default: 'inr' },
    status: {
      type: String,
      enum: ['pending', 'completed', 'failed', 'cancelled'],
      default: 'pending',
    },
    paymentMethod: { type: String, default: '' }, // card, upi, etc
    receiptUrl: { type: String, default: '' },
    errorMessage: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Payment', paymentSchema);
