/**
 * Fix-N-Go Load Test — Admin Panel
 * 
 * Run: k6 run load-tests/admin-load.js
 * Tests admin endpoints under concurrent admin sessions.
 */

import http from 'k6/http';
import { check, sleep, group } from 'k6';
import { Rate, Trend } from 'k6/metrics';

const adminError = new Rate('admin_error_rate');
const adminDuration = new Trend('admin_response_ms');
const BASE_URL = __ENV.BASE_URL || 'http://localhost:5000/api';
const ADMIN_EMAIL = __ENV.ADMIN_EMAIL || 'admin@fixngo.com';
const ADMIN_PASS = __ENV.ADMIN_PASS || 'Admin@SecurePass123';

export const options = {
  vus: 10,
  duration: '2m',
  thresholds: {
    http_req_duration: ['p(95)<1000'],
    admin_error_rate: ['rate<0.02'],
    admin_response_ms: ['p(95)<800'],
  },
};

function getAdminToken() {
  const res = http.post(`${BASE_URL}/auth/login`, JSON.stringify({
    email: ADMIN_EMAIL,
    password: ADMIN_PASS,
  }), { headers: { 'Content-Type': 'application/json' } });
  try { return JSON.parse(res.body).token; } catch { return null; }
}

export default function () {
  const token = getAdminToken();
  if (!token) { adminError.add(1); return; }

  const headers = { 'Content-Type': 'application/json', Authorization: `Bearer ${token}` };

  group('Admin Dashboard', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/admin/stats`, { headers });
    adminDuration.add(Date.now() - start);
    check(res, { 'stats: 200': (r) => r.status === 200 });
    if (res.status !== 200) adminError.add(1);
  });

  group('Admin Orders List', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/admin/orders?limit=50`, { headers });
    adminDuration.add(Date.now() - start);
    check(res, { 'orders: 200': (r) => r.status === 200 });
  });

  group('Admin Analytics', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/admin/analytics?days=7`, { headers });
    adminDuration.add(Date.now() - start);
    check(res, { 'analytics: 200': (r) => r.status === 200 });
  });

  group('Admin Live Map', () => {
    const start = Date.now();
    const res = http.get(`${BASE_URL}/admin/live-map`, { headers });
    adminDuration.add(Date.now() - start);
    check(res, { 'live-map: 200': (r) => r.status === 200 });
  });

  sleep(3);
}
