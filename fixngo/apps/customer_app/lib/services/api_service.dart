import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  String? _token;
  String? _refreshToken;
  static const Duration _timeout = Duration(seconds: 15);

  // Guard against concurrent refresh attempts
  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  final StorageService _storage = StorageService();

  void setToken(String? token) => _token = token;
  void setRefreshToken(String? token) => _refreshToken = token;

  /// Called on app start to restore persisted session.
  Future<void> restoreSession() async {
    _token = await _storage.getToken();
    _refreshToken = await _storage.getRefreshToken();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Bypass-Tunnel-Reminder': 'true',
        'ngrok-skip-browser-warning': 'true',
        if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/api/auth/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': 'customer',
    });
    await _persistTokens(data);
    return data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final data = await _post('/api/auth/register', {
      'name': name,
      'email': email.trim().toLowerCase(),
      'password': password,
      'role': 'customer',
    });
    await _persistTokens(data);
    return data;
  }

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    final token = data['token'] as String?;
    final refresh = data['refreshToken'] as String?;
    if (token != null) {
      _token = token;
      await _storage.saveToken(token);
    }
    if (refresh != null && refresh.isNotEmpty) {
      _refreshToken = refresh;
      await _storage.saveRefreshToken(refresh);
    }
  }

  /// Silently refreshes the access token using the stored refresh token.
  /// Returns true on success, false if refresh failed (session expired).
  Future<bool> _attemptRefresh() async {
    // If a refresh is already in flight, wait for it
    if (_isRefreshing) {
      return await _refreshCompleter!.future;
    }
    if (_refreshToken == null || _refreshToken!.isEmpty) return false;

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': _refreshToken}),
      ).timeout(_timeout);

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final newToken = body['token'] as String?;
        final newRefresh = body['refreshToken'] as String?;
        if (newToken != null) {
          _token = newToken;
          await _storage.saveToken(newToken);
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          _refreshToken = newRefresh;
          await _storage.saveRefreshToken(newRefresh);
        }
        _refreshCompleter!.complete(true);
        return true;
      } else {
        // Refresh token is invalid/expired — clear session
        await _storage.clear();
        _token = null;
        _refreshToken = null;
        _refreshCompleter!.complete(false);
        return false;
      }
    } catch (_) {
      _refreshCompleter!.complete(false);
      return false;
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    return _get('/api/auth/profile');
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? address,
    String? city,
    String? pincode,
  }) async {
    return _patch('/api/auth/profile', {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
    });
  }

  Future<Map<String, dynamic>> getOrderById(String id) async {
    return _get('/api/orders/$id');
  }

  Future<Map<String, dynamic>> getCatalog() async {
    return _get('/api/catalog');
  }

  Future<List<dynamic>> getTechnicians() async {
    final res = await _get('/api/technician');
    return res['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getOrders() async {
    final res = await _get('/api/orders');
    return res['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> createOrder({
    required String brand,
    required String model,
    required List<String> issues,
    required int total,
    String technician = '',
    String? customerPhone,
    String? serviceAddress,
    String? city,
    String? pincode,
    double? serviceLat,
    double? serviceLng,
  }) async {
    return _post('/api/orders', {
      'brand': brand,
      'model': model,
      'issues': issues,
      'total': total,
      'technician': technician,
      if (customerPhone != null) 'customerPhone': customerPhone,
      if (serviceAddress != null) 'serviceAddress': serviceAddress,
      if (city != null) 'city': city,
      if (pincode != null) 'pincode': pincode,
      if (serviceLat != null) 'serviceLat': serviceLat,
      if (serviceLng != null) 'serviceLng': serviceLng,
    });
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) => _post(path, body);
  Future<Map<String, dynamic>> get(String path) => _get(path);
  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) => _patch(path, body);

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) async {
    return _executeWithRefresh(() => http.patch(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        ).timeout(_timeout));
  }

  Future<Map<String, dynamic>> _get(String path) async {
    return _executeWithRefresh(() => http.get(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers,
        ).timeout(_timeout));
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    return _executeWithRefresh(() => http.post(
          Uri.parse('${ApiConfig.baseUrl}$path'),
          headers: _headers,
          body: jsonEncode(body),
        ).timeout(_timeout));
  }

  /// Executes an HTTP request. On 401, attempts one silent token refresh and retries.
  Future<Map<String, dynamic>> _executeWithRefresh(Future<http.Response> Function() requestFn) async {
    try {
      final res = await requestFn();

      if (res.statusCode == 401) {
        // Attempt a silent token refresh
        final refreshed = await _attemptRefresh();
        if (refreshed) {
          // Retry the original request with the new token
          final retryRes = await requestFn();
          return _decode(retryRes);
        } else {
          // Refresh failed — session is dead, surface a clear error
          throw ApiException('Session expired. Please log in again.', statusCode: 401);
        }
      }

      return _decode(res);
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your internet connection and try again.');
    } on SocketException {
      throw ApiException('No internet connection. Please check your network and try again.');
    }
  }

  dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? '{}' : res.body;
    final decoded = jsonDecode(body);
    if (res.statusCode >= 400) {
      final msg = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Request failed (${res.statusCode})';
      throw ApiException(msg, statusCode: res.statusCode);
    }
    return decoded;
  }
}
