/**
 * AES-256-GCM encryption/decryption for sensitive fields (Aadhaar, bank accounts).
 * AUDIT FIX §4.2: Aadhaar and bank data must not be stored as plaintext.
 *
 * Requires ENCRYPTION_KEY env var: 32-byte hex string (64 hex chars).
 * Generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
 */

const crypto = require('crypto');
const { logger } = require('./logger');

const ALGORITHM = 'aes-256-gcm';
const IV_LENGTH = 16;
const AUTH_TAG_LENGTH = 16;

/**
 * Get the encryption key from env, or return null in dev if not set.
 */
const getKey = () => {
  const keyHex = process.env.ENCRYPTION_KEY;
  if (!keyHex) {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('ENCRYPTION_KEY is required in production');
    }
    return null; // In dev, return null to signal encryption should be skipped
  }
  return Buffer.from(keyHex, 'hex');
};

/**
 * Encrypt a plaintext string.
 * Returns format: iv_hex:authTag_hex:ciphertext_hex
 * Returns the original value unchanged if ENCRYPTION_KEY is not set (dev mode).
 */
const encrypt = (plaintext) => {
  if (!plaintext) return plaintext;

  const key = getKey();
  if (!key) return plaintext; // Dev mode — no encryption

  const iv = crypto.randomBytes(IV_LENGTH);
  const cipher = crypto.createCipheriv(ALGORITHM, key, iv);

  let encrypted = cipher.update(plaintext, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag().toString('hex');

  return `${iv.toString('hex')}:${authTag}:${encrypted}`;
};

/**
 * Decrypt an encrypted string (iv_hex:authTag_hex:ciphertext_hex).
 * If the string doesn't look encrypted (no colons), returns it as-is
 * (handles legacy plaintext data gracefully).
 */
const decrypt = (encrypted) => {
  if (!encrypted) return encrypted;

  // If it doesn't match encrypted format, return as-is (legacy plaintext)
  if (!encrypted.includes(':') || encrypted.split(':').length !== 3) {
    return encrypted;
  }

  const key = getKey();
  if (!key) return encrypted; // Dev mode

  try {
    const [ivHex, authTagHex, ciphertext] = encrypted.split(':');
    const iv = Buffer.from(ivHex, 'hex');
    const authTag = Buffer.from(authTagHex, 'hex');

    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv);
    decipher.setAuthTag(authTag);

    let decrypted = decipher.update(ciphertext, 'hex', 'utf8');
    decrypted += decipher.final('utf8');

    return decrypted;
  } catch (err) {
    logger.error('Decryption failed — returning masked value', { error: err.message });
    return '****';
  }
};

/**
 * Mask a value, showing only the last N characters.
 * e.g. mask('123456789012', 4) => '********9012'
 */
const mask = (value, visibleChars = 4) => {
  if (!value) return '';
  const str = decrypt(value); // Decrypt first if encrypted
  if (str.length <= visibleChars) return str;
  return '*'.repeat(str.length - visibleChars) + str.slice(-visibleChars);
};

module.exports = { encrypt, decrypt, mask };
