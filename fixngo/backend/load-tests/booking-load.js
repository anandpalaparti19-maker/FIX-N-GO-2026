/**
 * Fix-N-Go Load Test Suite — k6
 * 
 * Run with: k6 run load-tests/booking-load.js
 * Install k6: https://k6.io/docs/getting-started/installation/
 * 
 * Scenarios:
 *   1. booking-spike   — 100 VUs for 30s (peak booking traffic)
 *   2. dispatch-soak   — 20 VUs for 5m  (sustained dispatch engine)
 *   3. payment-stress  — 50 VUs for 1m  (payment endpoint stress)
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Trend, Rate, Counter } from 'k6/metrics';

// ── Custom Metrics ─────────────────────────────────────────────────────────────
const bookingDuration = new Trend('booking_duration_ms');
const dispatchDuration = new Trend('dispatch_duration_ms');
const errorRate = new Rate('error_rate');
const bookingCount = new Counter('bookings_created');

// ── Config ────────────────────────────────────────────────────────────────────
const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000/api';

export const options = {
  scenarios: {
    booking_spike: {
      executor: 'ramping-vus',
      startVUs: 1,
      stages: [
        { duration: '10s', target: 50 },   // ramp up
        { duration: '30s', target: 100 },  // peak
        { duration: '10s', target: 0 },    // ramp down
      ],
      exec: 'bookingFlow',
      tags: { scenario: 'booking_spike' },
    },
    dispatch_soak: {
      executor: 'constant-vus',
      vus: 20,
      duration: '5m',
      exec: 'dispatchFlow',
      startTime: '50s', // start after booking spike
      tags: { scenario: 'dispatch_soak' },
    },
    payment_stress: {
      executor: 'ramping-arrival-rate',
      startRate: 10,
      timeUnit: '1s',
      preAllocatedVUs: 50,
      maxVUs: 100,
      stages: [
        { duration: '30s', target: 30 },
        { duration: '30s', target: 50 },
        { duration: '30s', target: 10 },
      ],
      exec: 'paymentFlow',
      startTime: '1m30s',
      tags: { scenario: 'payment_stress' },
    },
  },
  thresholds: {
    // 95th percentile response time < 500ms
    http_req_duration: ['p(95)<500'],
    // Error rate below 1%
    error_rate: ['rate<0.01'],
    // Booking p99 < 1s
    booking_duration_ms: ['p(99)<1000'],
    // Dispatch p95 < 300ms
    dispatch_duration_ms: ['p(95)<300'],
  },
};

// ── Shared State ──────────────────────────────────────────────────────────────

function registerAndLogin(role = 'customer') {
  const unique = `${Date.now()}_${Math.random().toString(36).slice(2)}`;
  const regRes = http.post(`${BASE_URL}/auth/register`, JSON.stringify({
    name: `Load Test ${role}`,
    email: `loadtest_${role}_${unique}@test.com`,
    password: 'LoadTest123!',
    role,
    phone: '9000000000',
  }), { headers: { 'Content-Type': 'application/json' } });

  check(regRes, { 'register: status 201': (r) => r.status === 201 });
  try {
    return JSON.parse(regRes.body).token;
  } catch {
    return null;
  }
}

function authHeaders(token) {
  return {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${token}`,
  };
}

// ── Scenarios ─────────────────────────────────────────────────────────────────

export function bookingFlow() {
  const token = registerAndLogin('customer');
  if (!token) { errorRate.add(1); return; }

  group('Create Order', () => {
    const start = Date.now();
    const res = http.post(`${BASE_URL}/orders`, JSON.stringify({
      brand: 'Samsung',
      model: 'Galaxy A54',
      issues: ['Screen crack', 'Battery'],
      total: 1200,
      serviceAddress: '12 Load Test St, Bangalore',
      city: 'Bangalore',
      pincode: '560001',
      serviceLat: 12.9716,
      serviceLng: 77.5946,
    }), { headers: authHeaders(token) });

    bookingDuration.add(Date.now() - start);
    const ok = check(res, {
      'order created: status 201': (r) => r.status === 201,
      'order created: has _id': (r) => { try { return !!JSON.parse(r.body).data._id; } catch { return false; } },
    });
    if (!ok) errorRate.add(1);
    else bookingCount.add(1);
  });

  group('List Orders', () => {
    const res = http.get(`${BASE_URL}/orders`, { headers: authHeaders(token) });
    check(res, { 'list orders: status 200': (r) => r.status === 200 });
  });

  sleep(1);
}

export function dispatchFlow() {
  const token = registerAndLogin('technician');
  if (!token) { errorRate.add(1); return; }

  // Set technician online with location
  group('Update Location', () => {
    const start = Date.now();
    const res = http.patch(`${BASE_URL}/tech/location`, JSON.stringify({
      lat: 12.9716 + (Math.random() * 0.01 - 0.005),
      lng: 77.5946 + (Math.random() * 0.01 - 0.005),
    }), { headers: authHeaders(token) });
    dispatchDuration.add(Date.now() - start);
    check(res, { 'location update: 200': (r) => r.status === 200 });
  });

  group('Get Offers', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/tech/jobs/offers`, { headers: authHeaders(token) });
    dispatchDuration.add(Date.now() - start);
    check(res, { 'get offers: 200': (r) => r.status === 200 });
  });

  group('Get Dashboard', () => {
    const res = http.get(`${BASE_URL}/tech/dashboard`, { headers: authHeaders(token) });
    check(res, { 'dashboard: 200': (r) => r.status === 200 });
  });

  sleep(2);
}

export function paymentFlow() {
  const token = registerAndLogin('customer');
  if (!token) { errorRate.add(1); return; }

  group('Create Payment Intent', () => {
    const res = http.post(`${BASE_URL}/payments/create-intent`, JSON.stringify({
      orderId: '000000000000000000000000', // non-existent — tests guard
      amount: 1200,
    }), { headers: authHeaders(token) });
    // Expect 404 (order not found) — proves the guard runs, not that Stripe runs
    check(res, {
      'payment intent guard: not 500': (r) => r.status !== 500,
      'payment intent guard: auth works': (r) => r.status !== 401,
    });
  });

  sleep(1);
}
