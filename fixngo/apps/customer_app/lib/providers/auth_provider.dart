import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userProfile;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userProfile => _userProfile;

  Future<bool> login(String email, String password) async {
    try {
      await _apiService.login(email, password);
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> fetchProfile() async {
    try {
      _userProfile = await _apiService.getProfile();
      notifyListeners();
    } catch (e) {
      // ignore
    }
  }
}
