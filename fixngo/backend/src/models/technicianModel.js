const mongoose = require('mongoose');

const technicianSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    role: { type: String, default: 'technician' },
    accountStatus: { type: String, enum: ['active', 'pending', 'suspended'], default: 'pending' },
    isApproved: { type: Boolean, default: false },
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
    technicianMeta: {
      emoji: { type: String, default: '🛠️' },
      rating: { type: Number, default: 4.8 },
      averageRating: { type: Number, default: 0 },
      totalRatings: { type: Number, default: 0 },
      experience: { type: String, default: '' },
      jobsDone: { type: Number, default: 0 },
      specialization: [{ type: String }],
      documents: {
        aadharNumber: { type: String, default: '' },
        aadharFront: { type: String, default: '' },
        aadharBack: { type: String, default: '' },
        aadhar: { type: String, default: '' },
        panCard: { type: String, default: '' },
        license: { type: String, default: '' },
      },
      bankDetails: {
        accountName: { type: String, default: '' },
        accountNumber: { type: String, default: '' },
        ifscCode: { type: String, default: '' },
      },
      verification: {
        status: { type: String, enum: ['unverified', 'pending', 'verified', 'rejected'], default: 'unverified' },
        aadhaarVerified: { type: Boolean, default: false },
      },
      walletBalance: { type: Number, default: 0 },
      pendingEarnings: { type: Number, default: 0 },
      totalEarnings: { type: Number, default: 0 },
    },
    passwordResetOtp: { type: String, default: '' },
    passwordResetOtpExpiry: { type: Date, default: null },
    fcmToken: { type: String, default: '' },
  },
  { timestamps: true }
);

technicianSchema.index({ location: '2dsphere' });

module.exports = mongoose.model('Technician', technicianSchema);
