// ── Test Environment Variables ─────────────────────────────────────────────
// These are safe dummy values used ONLY during Jest test runs.
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test_jwt_secret_not_for_production_32chars';
process.env.JWT_REFRESH_SECRET = 'test_refresh_secret_not_for_production';
process.env.JWT_EXPIRE = '1h';
process.env.CASHFREE_APP_ID = 'test_cashfree_app_id';
process.env.CASHFREE_SECRET_KEY = 'test_cashfree_secret_key';
process.env.CASHFREE_ENVIRONMENT = 'sandbox';
process.env.CASHFREE_PAYOUTS_ENABLED = 'false';
process.env.ENCRYPTION_KEY = 'a'.repeat(64); // 32-byte hex string for AES-256
process.env.SMTP_USER = 'test@example.com';
process.env.SMTP_PASS = 'test_smtp_pass';
process.env.MQTT_BROKER_URL = 'mqtt://localhost:1883';
process.env.SENTRY_DSN = '';

const { MongoMemoryReplSet } = require('mongodb-memory-server');
const mongoose = require('mongoose');

let mongoServer;

beforeAll(async () => {
  mongoServer = await MongoMemoryReplSet.create({ replSet: { count: 1 } });
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

afterEach(async () => {
  const collections = mongoose.connection.collections;
  for (const key in collections) {
    await collections[key].deleteMany({});
  }
});
