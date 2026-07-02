
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String _compileTimeBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );
  
  static String _dynamicBaseUrl = '';

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dynamicBaseUrl = prefs.getString('custom_api_url') ?? '';
    } catch (e) {
      // Ignore
    }
  }
  
  static Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('custom_api_url', url);
    _dynamicBaseUrl = url;
  }

  static String get baseUrl {
    if (_dynamicBaseUrl.isNotEmpty) return _dynamicBaseUrl;
    if (_compileTimeBaseUrl.isNotEmpty) return _compileTimeBaseUrl;
    
    // Default fallback
    return 'https://nasty-socks-yell.loca.lt';
  }

  static String get apiBaseUrl => '$baseUrl/api';
}
