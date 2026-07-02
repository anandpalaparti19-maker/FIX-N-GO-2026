require('./setup');
const request = require('supertest');
const { app } = require('../server');

describe('Auth — register', () => {
  const base = { name: 'Test User', email: 'test@example.com', password: 'password123' };

  it('registers a new customer and returns a token', async () => {
    const res = await request(app).post('/api/auth/register').send(base);
    expect(res.status).toBe(201);
    expect(res.body.token).toBeDefined();
    expect(res.body.role).toBe('customer');
  });

  it('rejects duplicate email with 409', async () => {
    await request(app).post('/api/auth/register').send(base);
    const res = await request(app).post('/api/auth/register').send(base);
    expect(res.status).toBe(409);
  });

  it('rejects missing fields with 400', async () => {
    const res = await request(app).post('/api/auth/register').send({ email: 'x@x.com' });
    expect(res.status).toBe(400);
  });
});

describe('Auth — login', () => {
  const creds = { name: 'Login User', email: 'login@example.com', password: 'password123' };

  beforeEach(async () => {
    await request(app).post('/api/auth/register').send(creds);
  });

  it('logs in with correct credentials', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: creds.email, password: creds.password });
    expect(res.status).toBe(200);
    expect(res.body.token).toBeDefined();
  });

  it('rejects wrong password with 401', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: creds.email, password: 'wrongpass' });
    expect(res.status).toBe(401);
  });

  it('rejects unknown email with 404', async () => {
    const res = await request(app)
      .post('/api/auth/login')
      .send({ email: 'nobody@example.com', password: 'password123' });
    expect(res.status).toBe(404);
  });
});

describe('Auth — profile', () => {
  let token;

  beforeEach(async () => {
    const res = await request(app)
      .post('/api/auth/register')
      .send({ name: 'Profile User', email: 'profile@example.com', password: 'password123' });
    token = res.body.token;
  });

  it('returns profile for authenticated user', async () => {
    const res = await request(app)
      .get('/api/auth/profile')
      .set('Authorization', `Bearer ${token}`);
    expect(res.status).toBe(200);
    expect(res.body.email).toBe('profile@example.com');
  });

  it('returns 401 without token', async () => {
    const res = await request(app).get('/api/auth/profile');
    expect(res.status).toBe(401);
  });
});
