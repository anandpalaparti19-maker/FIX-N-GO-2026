import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'fixngo_token';
  static const _userNameKey = 'fixngo_user_name';
  static const _userEmailKey = 'fixngo_user_email';

  Future<void> saveSession({
    required String token,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userNameKey, name);
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null || token.isEmpty) return null;
    return {
      'token': token,
      'name': prefs.getString(_userNameKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
    };
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
