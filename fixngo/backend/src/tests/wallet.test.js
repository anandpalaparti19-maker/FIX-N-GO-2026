require('./setup');
const request = require('supertest');
const { app } = require('../server');
const User = require('../models/userModel');
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Technician = require('../models/technicianModel');
const Withdrawal = require('../models/withdrawalModel');
const WalletTransaction = require('../models/walletTransactionModel');

beforeAll(async () => {
  await Technician.createCollection();
  await Withdrawal.createCollection();
  await WalletTransaction.createCollection();
});

const createVerifiedTechnician = async () => {
  const salt = await bcrypt.genSalt(10);
  const password = await bcrypt.hash('password123', salt);
  const tech = await User.create({
    name: 'Test Technician',
    email: `tech_${Date.now()}@example.com`,
    password,
    role: 'technician',
    accountStatus: 'active',
    isApproved: true,
    technicianMeta: {
      walletBalance: 2000,
      verification: { status: 'verified', aadhaarVerified: true },
      bankDetails: {
        accountName: 'Test Tech',
        accountNumber: '1234567890',
        ifscCode: 'SBIN0001234',
      },
    },
  });

  // Login to get token
  const res = await request(app).post('/api/auth/login').send({
    email: tech.email,
    password: 'password123',
  });
  return { tech, token: res.body.token };
};

describe('Wallet — withdrawal', () => {
  it('rejects withdrawal for non-technician', async () => {
    const regRes = await request(app).post('/api/auth/register').send({
      name: 'Customer',
      email: `cust_${Date.now()}@example.com`,
      password: 'password123',
    });
    const res = await request(app)
      .post('/api/wallet/withdraw')
      .set('Authorization', `Bearer ${regRes.body.token}`)
      .send({ amount: 500 });
    expect(res.status).toBe(403);
  });

  it('rejects withdrawal below ₹500 minimum', async () => {
    const { token } = await createVerifiedTechnician();
    const res = await request(app)
      .post('/api/wallet/withdraw')
      .set('Authorization', `Bearer ${token}`)
      .send({ amount: 100 });
    expect(res.status).toBe(400);
    expect(res.body.message).toMatch(/minimum/i);
  });

  it('rejects withdrawal exceeding wallet balance', async () => {
    const { token } = await createVerifiedTechnician();
    const res = await request(app)
      .post('/api/wallet/withdraw')
      .set('Authorization', `Bearer ${token}`)
      .send({ amount: 99999 });
    expect(res.status).toBe(400);
    expect(res.body.message).toMatch(/insufficient/i);
  });

  it('accepts valid withdrawal and debits wallet (payouts disabled mode)', async () => {
    const { token, tech } = await createVerifiedTechnician();
    const res = await request(app)
      .post('/api/wallet/withdraw')
      .set('Authorization', `Bearer ${token}`)
      .send({ amount: 500 });

    // Should succeed (payouts disabled by default in test env)
    if (res.status !== 200) console.error('WALLET WITHDRAWAL FAILED:', res.status, res.body);
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);

    // Wallet balance should be debited
    const updated = await User.findById(tech._id);
    expect(updated.technicianMeta.walletBalance).toBe(1500);
  });
});
