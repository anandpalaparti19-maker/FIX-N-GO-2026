import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../api_service_new.dart';

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM: Handling a background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService instance = PushNotificationService._internal();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _apiService = ApiService();

  PushNotificationService._internal();

  /// Initialize FCM, request permissions, and set up listeners
  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('FCM: Web push not fully configured, skipping FCM setup');
      return;
    }

    try {
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
        
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('FCM: Received foreground message: ${message.notification?.title}');
        });

        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          debugPrint('FCM: User tapped notification, opened app. Data: ${message.data}');
        });

        await _updateFCMToken();

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
    final authToken = _apiService.token;
    if (authToken == null || authToken.isEmpty) {
      debugPrint('FCM: User not logged in, cannot save FCM token to backend');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${_apiService.baseUrl}/auth/fcm-token'),
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
