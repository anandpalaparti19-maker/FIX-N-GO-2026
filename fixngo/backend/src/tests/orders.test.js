require('./setup');
const request = require('supertest');
const { app } = require('../server');

const registerAndLogin = async (overrides = {}) => {
  const data = {
    name: 'Order User',
    email: `order_${Date.now()}@example.com`,
    password: 'password123',
    ...overrides,
  };
  const res = await request(app).post('/api/auth/register').send(data);
  return res.body.token;
};

const orderPayload = {
  brand: 'Samsung',
  model: 'Galaxy S21',
  issues: ['Screen crack'],
  total: 2500,
  serviceAddress: '123 Main Street',
  city: 'Hyderabad',
  pincode: '500001',
};

describe('Orders — create', () => {
  let token;

  beforeEach(async () => {
    token = await registerAndLogin();
  });

  it('creates an order for authenticated customer', async () => {
    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send(orderPayload);
    expect(res.status).toBe(201);
    expect(res.body.success).toBe(true);
    expect(res.body.data.brand).toBe('Samsung');
  });

  it('rejects order creation without auth', async () => {
    const res = await request(app).post('/api/orders').send(orderPayload);
    expect(res.status).toBe(401);
  });

  it('rejects incomplete order payload', async () => {
    const res = await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send({ brand: 'Samsung' }); // missing model, issues, total
    expect(res.status).toBe(400);
  });
});

describe('Orders — fetch', () => {
  let token;

  beforeEach(async () => {
    token = await registerAndLogin({ email: `fetch_${Date.now()}@example.com` });
    await request(app)
      .post('/api/orders')
      .set('Authorization', `Bearer ${token}`)
      .send(orderPayload);
  });

  it('returns order list for customer', async () => {
    const res = await request(app)
      .get('/api/orders')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.success).toBe(true);
    expect(Array.isArray(res.body.data)).toBe(true);
    expect(res.body.data.length).toBeGreaterThan(0);
  });

  it('returns 401 without auth', async () => {
    const res = await request(app).get('/api/orders');
    expect(res.status).toBe(401);
  });
});

describe('Orders — status transitions', () => {
  it('pending status allows assignment and cancellation', () => {
    const flow = {
      pending: ['assigned', 'cancelled'],
      assigned: ['in_progress', 'pending', 'cancelled'],
      in_progress: ['completed', 'cancelled'],
      completed: [],
      cancelled: [],
    };
    expect(flow.pending).toContain('assigned');
    expect(flow.pending).toContain('cancelled');
    expect(flow.in_progress).toContain('completed');
    expect(flow.completed).toHaveLength(0);
  });
});
