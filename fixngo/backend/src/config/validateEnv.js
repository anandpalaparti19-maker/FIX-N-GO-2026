/**
 * Centralized environment variable validation.
 * Rejects known weak/default secrets in production.
 * Called at server startup before any connections are made.
 */

const KNOWN_WEAK_SECRETS = [
  'CHANGE_ME_generate_with_crypto_randomBytes_64',
  'your-secret-key',
  'secret',
  'jwt_secret',
  'changeme',
  'password',
  'default',
];

const validateEnv = () => {
  const errors = [];
  const warnings = [];
  const isProduction = process.env.NODE_ENV === 'production';

  // ── Required in ALL environments ──────────────────────────────────
  const requiredAlways = ['MONGO_URI', 'JWT_SECRET', 'PORT'];
  for (const key of requiredAlways) {
    if (!process.env[key]) {
      errors.push(`Missing required env var: ${key}`);
    }
  }

  // ── JWT_SECRET strength ──────────────────────────────────────────
  const jwtSecret = process.env.JWT_SECRET || '';
  if (KNOWN_WEAK_SECRETS.some((weak) => jwtSecret.toLowerCase().includes(weak.toLowerCase()))) {
    const msg = 'JWT_SECRET is set to a known default/weak value. Generate a secure one: node -e "console.log(require(\'crypto\').randomBytes(64).toString(\'hex\'))"';
    if (isProduction) {
      errors.push(msg);
    } else {
      warnings.push(msg);
    }
  }
  if (jwtSecret.length < 32) {
    const msg = `JWT_SECRET is only ${jwtSecret.length} chars. Minimum recommended: 64 chars.`;
    if (isProduction) {
      errors.push(msg);
    } else {
      warnings.push(msg);
    }
  }

  // ── Production-only requirements ──────────────────────────────────
  if (isProduction) {
    // AUDIT FIX §4.4: Require Cashfree keys (actually used) instead of Stripe (dead code)
    const requiredProd = [
      'CASHFREE_APP_ID',
      'CASHFREE_SECRET_KEY',
      'ENCRYPTION_KEY',
      'SMTP_USER',
      'SMTP_PASS',
    ];
    for (const key of requiredProd) {
      const val = process.env[key] || '';
      if (!val || val === 'your-email@gmail.com' || val === 'your-app-password' || val.startsWith('test_') || val.startsWith('xxxx')) {
        errors.push(`${key} is missing or set to a placeholder value`);
      }
    }

    // CORS must not be localhost-only in production
    const corsOrigins = process.env.CORS_ORIGINS || '';
    if (!corsOrigins || corsOrigins.includes('localhost')) {
      warnings.push('CORS_ORIGINS contains localhost origins — ensure production domains are set');
    }

    // MQTT credentials should be set
    if (!process.env.MQTT_USER || !process.env.MQTT_PASSWORD) {
      warnings.push('MQTT_USER and MQTT_PASSWORD are not set — broker may be running unauthenticated');
    }
  }

  // ── Report ────────────────────────────────────────────────────────
  if (warnings.length > 0) {
    console.warn('\n⚠️  Environment warnings:');
    warnings.forEach((w) => console.warn(`   • ${w}`));
  }

  if (errors.length > 0) {
    console.error('\n❌ Environment validation FAILED:');
    errors.forEach((e) => console.error(`   • ${e}`));
    if (isProduction) {
      console.error('\nRefusing to start in production with invalid configuration.\n');
      process.exit(1);
    } else {
      console.warn('\n⚠️  Running in development mode with configuration issues. Fix before deploying.\n');
    }
  }

  return { errors, warnings };
};

module.exports = { validateEnv };
