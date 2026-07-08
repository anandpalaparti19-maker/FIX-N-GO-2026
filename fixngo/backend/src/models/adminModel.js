const mongoose = require('mongoose');

const adminSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true, lowercase: true, trim: true },
    password: { type: String, required: true },
    role: { type: String, default: 'admin' },
    accountStatus: { type: String, enum: ['active', 'suspended'], default: 'active' },
    isApproved: { type: Boolean, default: true },
    phone: { type: String, default: '' },
    profilePhoto: { type: String, default: '' },
    adminMeta: {
      permissions: [{ type: String }],
      managedModules: [{ type: String }],
      lastLoginAt: { type: Date, default: null },
      notes: { type: String, default: '' },
    },
    passwordResetOtp: { type: String, default: '' },
    passwordResetOtpExpiry: { type: Date, default: null },
    fcmToken: { type: String, default: '' },
  },
  { timestamps: true }
);

module.exports = mongoose.model('Admin', adminSchema);
