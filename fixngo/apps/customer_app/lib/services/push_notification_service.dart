import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';
import '../utils/constants.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you need to handle background data payloads, do it here.
  // Avoid heavy logic or UI updates.
  debugPrint('FCM: Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final AuthProvider _authProvider;

  PushNotificationService(this._authProvider);

  /// Initialize FCM, request permissions, and set up listeners
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('FCM: Web push not fully configured, skipping FCM setup');
      return;
    }

    try {
      // 1. Request Permission (iOS requires this, Android 13+ requires this)
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('FCM: User granted permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        
        // 2. Set up background handler
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // 3. Listen to foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCM: Received foreground message: ${message.notification?.title}');
          // Note: FlutterLocalNotifications can be added here to show heads-up
          // notifications while the app is in the foreground.
        });

        // 4. Handle notification taps when app is in background but opened
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FCM: User tapped notification, opened app. Data: ${message.data}');
          // Navigation logic can be handled here based on message.data
        });

        // 5. Check if app was opened from a terminated state via notification tap
        final initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          debugPrint('FCM: App opened from terminated state via notification');
        }

        // 6. Get FCM Token and send to backend
        await _updateFCMToken();

        // 7. Listen for token refreshes
        _fcm.onTokenRefresh.listen((newToken) {
          debugPrint('FCM: Token refreshed');
          _sendTokenToBackend(newToken);
        });
      }
    } catch (e) {
      debugPrint('FCM: Initialization failed: $e');
    }
  }

  /// Fetch token and update backend if authenticated
  Future<void> _updateFCMToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        debugPrint('FCM: Device Token retrieved: ${token.substring(0, 10)}...');
        await _sendTokenToBackend(token);
      }
    } catch (e) {
      debugPrint('FCM: Error getting token: $e');
    }
  }

  /// Sends the FCM token to the backend server
  Future<void> _sendTokenToBackend(String fcmToken) async {
    final authToken = _authProvider.token;
    if (authToken == null || authToken.isEmpty) {
      debugPrint('FCM: User not logged in, cannot save FCM token to backend');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/auth/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'fcmToken': fcmToken}),
      );

      if (response.statusCode == 200) {
        debugPrint('FCM: Token successfully saved to backend');
      } else {
        debugPrint('FCM: Failed to save token to backend. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('FCM: Error sending token to backend: $e');
    }
  }
}
