import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/push_notification_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  bool _isAuthenticated = false;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;
  String? _token;

  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;
  String? get token => _token;

  Future<bool> tryAutoLogin() async {
    try {
      final user = await _storageService.getUser();
      if (user != null && user['token'] != null && user['token']!.isNotEmpty) {
        _token = user['token'];
        // Restore both tokens into the API service before making any request
        await _apiService.restoreSession();

        final fetched = await fetchProfile();
        _isAuthenticated = fetched;
        if (!fetched) {
          await logout();
        } else {
          // Init push notifications once authed
          PushNotificationService(this).initialize();
        }
        notifyListeners();
        return fetched;
      }
    } catch (e) {
      // ignore
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    try {
      // _apiService.login() already persists both tokens internally
      final data = await _apiService.login(email, password);
      final tokenStr = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final name = (data['name'] as String?) ?? '';
      final emailNorm = email.trim().toLowerCase();

      await _storageService.saveSession(
        token: tokenStr,
        name: name,
        email: emailNorm,
        refreshToken: refreshToken,
      );
      _token = tokenStr;
      _isAuthenticated = true;
      await fetchProfile();
      PushNotificationService(this).initialize();
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      _errorMessage = null;
      final data = await _apiService.register(name, email, password);
      final tokenStr = data['token'] as String;
      final refreshToken = data['refreshToken'] as String?;
      final emailNorm = email.trim().toLowerCase();

      await _storageService.saveSession(
        token: tokenStr,
        name: name,
        email: emailNorm,
        refreshToken: refreshToken,
      );
      _token = tokenStr;
      _isAuthenticated = true;

      final profileFetched = await fetchProfile();
      if (!profileFetched) {
        _errorMessage = 'Registration successful, but failed to fetch profile.';
      } else {
        PushNotificationService(this).initialize();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? pincode,
  }) async {
    try {
      await _apiService.updateProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        pincode: pincode,
      );
      await fetchProfile();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.clear();
    _apiService.setToken(null);
    _apiService.setRefreshToken(null);
    _isAuthenticated = false;
    _userProfile = null;
    _token = null;
    notifyListeners();
  }

  Future<bool> fetchProfile() async {
    try {
      final response = await _apiService.getProfile();
      _userProfile = response;
      notifyListeners();
      return true;
    } catch (e) {
      // If we get a 401 that persists after refresh, force logout
      if (e is ApiException && e.statusCode == 401) {
        await logout();
      }
      _userProfile = null;
      return false;
    }
  }
}

