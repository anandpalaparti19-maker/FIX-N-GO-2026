import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class ApiConfig {
  static const String _overrideBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) return _overrideBaseUrl;
    if (kIsWeb) return 'https://nasty-socks-yell.loca.lt';
    if (defaultTargetPlatform == TargetPlatform.android) return 'https://nasty-socks-yell.loca.lt';
    return 'https://nasty-socks-yell.loca.lt';
  }

  static String get apiBaseUrl => '$baseUrl/api';
}
