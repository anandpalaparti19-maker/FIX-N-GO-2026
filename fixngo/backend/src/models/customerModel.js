const mongoose = require('mongoose');

const customerSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    role: { type: String, default: 'customer' },
    accountStatus: { type: String, enum: ['active', 'pending', 'suspended'], default: 'active' },
    isApproved: { type: Boolean, default: true },
    phone: { type: String, default: '' },
    address: { type: String, default: '' },
    city: { type: String, default: 'Hyderabad' },
    pincode: { type: String, default: '' },
    profilePhoto: { type: String, default: '' },
    notificationPrefs: {
      push: { type: Boolean, default: true },
      sms: { type: Boolean, default: false },
      email: { type: Boolean, default: true },
      orderUpdates: { type: Boolean, default: true },
      payments: { type: Boolean, default: true },
      promotions: { type: Boolean, default: false },
    },
    isOnline: { type: Boolean, default: false },
    lastLat: { type: Number, default: null },
    lastLng: { type: Number, default: null },
    lastLocationUpdate: { type: Date, default: null },
    location: {
      type: { type: String, default: 'Point' },
      coordinates: { type: [Number], default: [0, 0] },
    },
    customerMeta: {
      savedAddresses: [
        {
          label: { type: String, default: '' },
          address: { type: String, default: '' },
          city: { type: String, default: '' },
          pincode: { type: String, default: '' },
          isDefault: { type: Boolean, default: false },
        },
      ],
      favoriteServices: [{ type: String }],
      serviceCount: { type: Number, default: 0 },
      lastServiceAt: { type: Date, default: null },
      preferredContact: { type: String, enum: ['phone', 'email', 'whatsapp'], default: 'phone' },
    },
    passwordResetOtp: { type: String, default: '' },
    passwordResetOtpExpiry: { type: Date, default: null },
    fcmToken: { type: String, default: '' },
  },
  { timestamps: true }
);

customerSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Customer', customerSchema);
