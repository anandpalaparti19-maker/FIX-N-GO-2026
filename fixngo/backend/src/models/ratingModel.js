const mongoose = require('mongoose');

const ratingSchema = mongoose.Schema(
  {
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    technicianId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    rating: {
      type: Number,
      required: true,
      min: 1,
      max: 5,
    },
    review: { type: String, default: '' },
    categories: {
      professionalism: { type: Number, min: 1, max: 5 },
      quality: { type: Number, min: 1, max: 5 },
      punctuality: { type: Number, min: 1, max: 5 },
      communication: { type: Number, min: 1, max: 5 },
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Rating', ratingSchema);
