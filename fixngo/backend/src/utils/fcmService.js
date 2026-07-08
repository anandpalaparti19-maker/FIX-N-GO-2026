/**
 * Firebase Cloud Messaging (FCM) Push Notification Service
 *
 * Sends push notifications to user devices via Firebase Admin SDK.
 * Requires FIREBASE_SERVICE_ACCOUNT_PATH env var pointing to the
 * service account JSON downloaded from Firebase Console.
 *
 * Usage:
 *   const { sendPush, sendPushToMany } = require('./fcmService');
 *   await sendPush(userId, { title: '...', body: '...' });
 */

const { logger } = require('./logger');

let admin = null;
let messaging = null;

/**
 * Lazy-initialize Firebase Admin SDK.
 * Returns null if credentials are not configured.
 */
function getMessaging() {
  if (messaging) return messaging;

  try {
    const firebaseAdmin = require('firebase-admin');

    if (firebaseAdmin.apps.length === 0) {
      const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

      if (serviceAccountPath) {
        const serviceAccount = require(serviceAccountPath);
        firebaseAdmin.initializeApp({
          credential: firebaseAdmin.credential.cert(serviceAccount),
        });
      } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
        // Falls back to GOOGLE_APPLICATION_CREDENTIALS env var
        firebaseAdmin.initializeApp();
      } else {
        logger.warn('FCM: No Firebase credentials configured — push notifications disabled');
        return null;
      }
    }

    admin = firebaseAdmin;
    messaging = firebaseAdmin.messaging();
    logger.info('FCM: Firebase Admin SDK initialized');
    return messaging;
  } catch (error) {
    logger.warn('FCM: Failed to initialize Firebase Admin SDK', { error: error.message });
    return null;
  }
}

/**
 * Send a push notification to a single user by their FCM token.
 *
 * @param {string} fcmToken - The device FCM registration token
 * @param {object} notification - { title, body, imageUrl? }
 * @param {object} [data] - Optional key-value data payload
 * @returns {Promise<string|null>} Message ID or null on failure
 */
async function sendToToken(fcmToken, notification, data = {}) {
  const msg = getMessaging();
  if (!msg || !fcmToken) return null;

  try {
    const message = {
      token: fcmToken,
      notification: {
        title: notification.title,
        body: notification.body,
        ...(notification.imageUrl && { imageUrl: notification.imageUrl }),
      },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: {
          channelId: 'fixngo_default',
          sound: 'default',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: {
            sound: 'default',
            badge: 1,
          },
        },
      },
    };

    const messageId = await msg.send(message);
    logger.info('FCM: Push sent', { messageId, title: notification.title });
    return messageId;
  } catch (error) {
    // Handle invalid/expired tokens
    if (
      error.code === 'messaging/invalid-registration-token' ||
      error.code === 'messaging/registration-token-not-registered'
    ) {
      logger.warn('FCM: Invalid/expired token — should be removed', { fcmToken: fcmToken.slice(0, 12) + '...' });
      return null;
    }
    logger.error('FCM: Failed to send push', { error: error.message });
    return null;
  }
}

/**
 * Send a push notification to a user by their MongoDB user ID.
 * Looks up the user's fcmToken from the database.
 *
 * @param {string} userId - MongoDB user _id
 * @param {object} notification - { title, body, imageUrl? }
 * @param {object} [data] - Optional key-value data payload
 */
async function sendPush(userId, notification, data = {}) {
  try {
    const User = require('../models/userModel');
    const user = await User.findById(userId);
    if (!user || !user.fcmToken) {
      logger.debug('FCM: No FCM token for user', { userId });
      return null;
    }
    return await sendToToken(user.fcmToken, notification, data);
  } catch (error) {
    logger.error('FCM: sendPush error', { userId, error: error.message });
    return null;
  }
}

/**
 * Send push notifications to multiple users.
 *
 * @param {string[]} userIds - Array of MongoDB user _ids
 * @param {object} notification - { title, body }
 * @param {object} [data] - Optional data payload
 * @returns {Promise<{ successCount: number, failureCount: number }>}
 */
async function sendPushToMany(userIds, notification, data = {}) {
  const msg = getMessaging();
  if (!msg || !userIds.length) return { successCount: 0, failureCount: 0 };

  try {
    const User = require('../models/userModel');
    const users = await User.find({ _id: { $in: userIds }, fcmToken: { $ne: '' } });
    const tokens = users.map((u) => u.fcmToken).filter(Boolean);

    if (tokens.length === 0) return { successCount: 0, failureCount: 0 };

    const message = {
      notification: {
        title: notification.title,
        body: notification.body,
      },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: { channelId: 'fixngo_default', sound: 'default' },
      },
      tokens,
    };

    const response = await msg.sendEachForMulticast(message);
    logger.info('FCM: Multicast sent', {
      successCount: response.successCount,
      failureCount: response.failureCount,
    });
    return { successCount: response.successCount, failureCount: response.failureCount };
  } catch (error) {
    logger.error('FCM: sendPushToMany error', { error: error.message });
    return { successCount: 0, failureCount: userIds.length };
  }
}

module.exports = { sendToToken, sendPush, sendPushToMany };
