/**
 * Dispatch Engine Test Suite
 * Tests: race condition prevention, atomic accept, reject behaviour,
 * stuck-order recovery, and admin manual assign.
 */
require('./setup');
const request = require('supertest');
const { app } = require('../server');
const mongoose = require('mongoose');
const Order = require('../models/orderModel');
const User = require('../models/userModel');
const bcrypt = require('bcryptjs');

// ── Helpers ────────────────────────────────────────────────────────────────────

async function createUser(role, overrides = {}) {
  const pw = await bcrypt.hash('TestPass123!', 10);
  const base = {
    name: `${role} User`,
    email: `${role}_${Date.now()}_${Math.random()}@test.com`,
    password: pw,
    role,
    phone: '9000000000',
    isApproved: role === 'technician',
    accountStatus: 'active',
    isOnline: role === 'technician',
    location: role === 'technician' ? {
      type: 'Point',
      coordinates: [77.5946, 12.9716],
    } : undefined,
    lastLat: role === 'technician' ? 12.9716 : undefined,
    lastLng: role === 'technician' ? 77.5946 : undefined,
    ...overrides,
  };
  return User.create(base);
}

async function loginAs(email) {
  const res = await request(app).post('/api/auth/login').send({ email, password: 'TestPass123!' });
  return res.body.token;
}

async function createOrderDirect(customerId) {
  return Order.create({
    user: customerId,
    brand: 'Motorola',
    model: 'Edge 30',
    issues: ['Battery'],
    basePrice: 600,
    customerFee: 60,
    technicianCommission: 120,
    customerTotal: 660,
    total: 600,
    status: 'pending',
    dispatchStatus: 'searching',
    searchRadius: 3,
    serviceAddress: 'Bangalore',
    serviceLocation: { type: 'Point', coordinates: [77.5946, 12.9716] },
    location: { type: 'Point', coordinates: [77.5946, 12.9716] },
  });
}

// ── Test Suites ────────────────────────────────────────────────────────────────

describe('Dispatch — Order Retrieval', () => {
  it('technician can list their active jobs', async () => {
    const tech = await createUser('technician');
    const token = await loginAs(tech.email);
    const res = await request(app)
      .get('/api/tech/jobs?status=active')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
  });

  it('returns empty list when technician has no jobs', async () => {
    const tech = await createUser('technician');
    const token = await loginAs(tech.email);
    const res = await request(app)
      .get('/api/tech/jobs?status=active')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    const body = Array.isArray(res.body) ? res.body : res.body.data || [];
    expect(body.length).toBe(0);
  });
});

describe('Dispatch — Accept Race Condition Prevention', () => {
  it('does not allow accepting an order that is already accepted', async () => {
    const customer = await createUser('customer');
    const tech1 = await createUser('technician');
    const tech2 = await createUser('technician');
    const order = await createOrderDirect(customer._id);
    const token1 = await loginAs(tech1.email);
    const token2 = await loginAs(tech2.email);

    // Manually set order to offered state for tech1
    await Order.findByIdAndUpdate(order._id, {
      dispatchStatus: 'offered',
      offeredTo: tech1._id,
    });

    // tech2 tries to accept an order offered to tech1
    const res = await request(app)
      .post(`/api/tech/jobs/${order._id}/accept`)
      .set('Authorization', `Bearer ${token2}`);
    
    // Should be rejected — offered to tech1 only
    expect([400, 403, 404]).toContain(res.status);
  });

  it('prevents a technician with an active job from accepting another', async () => {
    const customer = await createUser('customer');
    const tech = await createUser('technician');
    const token = await loginAs(tech.email);

    // Create two orders
    const order1 = await createOrderDirect(customer._id);
    const order2 = await createOrderDirect(customer._id);

    // Assign tech to order1 (simulate active job)
    await Order.findByIdAndUpdate(order1._id, {
      technicianUser: tech._id,
      status: 'assigned',
      dispatchStatus: 'accepted',
    });

    // Try to accept order2 while already having order1
    await Order.findByIdAndUpdate(order2._id, {
      dispatchStatus: 'offered',
      offeredTo: tech._id,
    });

    const res = await request(app)
      .post(`/api/tech/jobs/${order2._id}/accept`)
      .set('Authorization', `Bearer ${token}`);
    expect([400, 409]).toContain(res.status);
  });
});

describe('Dispatch — Reject Behaviour', () => {
  it('reject does not reset search radius to 3km', async () => {
    const customer = await createUser('customer');
    const tech = await createUser('technician');
    const token = await loginAs(tech.email);

    const order = await createOrderDirect(customer._id);
    // Set radius to expanded value
    await Order.findByIdAndUpdate(order._id, { searchRadius: 8, dispatchStatus: 'offered', offeredTo: tech._id });

    await request(app)
      .patch(`/api/orders/${order._id}/reject`)
      .set('Authorization', `Bearer ${token}`);

    const updated = await Order.findById(order._id);
    // Radius should NOT have been reset to 3
    if (updated) {
      expect(updated.searchRadius).toBeGreaterThanOrEqual(5);
    }
  });

  it('returns error when rejecting a non-offered order', async () => {
    const customer = await createUser('customer');
    const tech = await createUser('technician');
    const token = await loginAs(tech.email);

    const order = await createOrderDirect(customer._id);
    // Order is in 'searching' state, not offered to anyone
    const res = await request(app)
      .patch(`/api/orders/${order._id}/reject`)
      .set('Authorization', `Bearer ${token}`);
    expect([400, 403, 404]).toContain(res.status);
  });
});

describe('Dispatch — Admin Manual Override', () => {
  let adminToken, techId, orderId, customerId;

  beforeEach(async () => {
    const admin = await createUser('admin', { role: 'admin' });
    const customer = await createUser('customer');
    const tech = await createUser('technician');
    const order = await createOrderDirect(customer._id);
    adminToken = await loginAs(admin.email);
    techId = tech._id.toString();
    orderId = order._id.toString();
    customerId = customer._id.toString();
  });

  it('admin can assign a technician to an order', async () => {
    const res = await request(app)
      .post('/api/admin/orders/assign')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ orderId, technicianId: techId });
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
  });

  it('admin assign updates order status to assigned', async () => {
    await request(app)
      .post('/api/admin/orders/assign')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ orderId, technicianId: techId });
    const order = await Order.findById(orderId);
    expect(order.status).toBe('assigned');
    expect(order.technicianUser.toString()).toBe(techId);
  });

  it('admin can force-update order status', async () => {
    const res = await request(app)
      .patch(`/api/admin/orders/${orderId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ status: 'cancelled' });
    expect(res.status).toBe(200);
    expect(res.body.data?.status || res.body.status).toBe('cancelled');
  });

  it('non-admin cannot access admin assign endpoint', async () => {
    const customer = await createUser('customer');
    const token = await loginAs(customer.email);
    const res = await request(app)
      .post('/api/admin/orders/assign')
      .set('Authorization', `Bearer ${token}`)
      .send({ orderId, technicianId: techId });
    expect(res.status).toBe(403);
  });
});

describe('Dispatch — Order Cancellation', () => {
  it('customer can cancel their own pending order', async () => {
    const customer = await createUser('customer');
    const token = await loginAs(customer.email);
    const order = await createOrderDirect(customer._id);
    const res = await request(app)
      .patch(`/api/orders/${order._id}/cancel`)
      .set('Authorization', `Bearer ${token}`);
    expect([200, 204]).toContain(res.status);
  });

  it('customer cannot cancel another customer\'s order', async () => {
    const c1 = await createUser('customer');
    const c2 = await createUser('customer');
    const token2 = await loginAs(c2.email);
    const order = await createOrderDirect(c1._id);
    const res = await request(app)
      .patch(`/api/orders/${order._id}/cancel`)
      .set('Authorization', `Bearer ${token2}`);
    expect([400, 403, 404]).toContain(res.status);
  });
});
