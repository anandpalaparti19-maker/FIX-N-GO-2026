import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/api_config.dart';

class ApiService {
  static String get apiBaseUrl {
    return ApiConfig.apiBaseUrl;
  }

  static String imageUrl(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    return '${ApiConfig.baseUrl}$path';
  }

  static const String _tokenKey = 'token';
  static const String _refreshTokenKey = 'refresh_token';

  // ── Token persistence ──────────────────────────────────────────────────────

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> _saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, token);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // ── Headers ────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── Silent token refresh ───────────────────────────────────────────────────

  bool _isRefreshing = false;
  Completer<bool>? _refreshCompleter;

  /// Silently refreshes the access token. Returns true on success.
  Future<bool> _attemptRefresh() async {
    if (_isRefreshing) return await _refreshCompleter!.future;

    final refreshToken = await _getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) return false;

    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final newToken = body['token'] as String?;
        final newRefresh = body['refreshToken'] as String?;
        if (newToken != null) await saveToken(newToken);
        if (newRefresh != null && newRefresh.isNotEmpty) await _saveRefreshToken(newRefresh);
        _refreshCompleter!.complete(true);
        return true;
      } else {
        await clearSession();
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

  /// Executes a request and retries once after a silent refresh on 401.
  Future<http.Response> _execute(Future<http.Response> Function(Map<String, String> headers) requestFn) async {
    final headers = await _getHeaders();
    final res = await requestFn(headers);

    if (res.statusCode == 401) {
      final refreshed = await _attemptRefresh();
      if (refreshed) {
        final newHeaders = await _getHeaders();
        return await requestFn(newHeaders);
      }
    }
    return res;
  }

  // ── Auth ───────────────────────────────────────────────────────────────────

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'role': 'technician',
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final tokenStr = data['token']?.toString();
        if (tokenStr == null || tokenStr.isEmpty) {
          throw Exception('Invalid server response. Ensure your Serveo/Ngrok URL is correct.');
        }
        await saveToken(tokenStr);
        final refresh = data['refreshToken']?.toString();
        if (refresh != null && refresh.isNotEmpty) await _saveRefreshToken(refresh);
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Invalid credentials');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection failed');
    }
  }

  // ── Wrapped API calls (with silent refresh) ───────────────────────────────

  Future<List<dynamic>> getIncomingOffers() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/jobs/offers'), headers: h));
      if (res.statusCode == 401) return [];
      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getAvailableJobs() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/orders/available'), headers: h));
      if (res.statusCode == 401) return [];
      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  Future<bool> acceptJob(String orderId) async {
    try {
      final res = await _execute((h) => http.post(Uri.parse('$apiBaseUrl/tech/jobs/$orderId/accept'), headers: h));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejectJob(String orderId) async {
    try {
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/orders/$orderId/reject'),
            headers: h,
          ));
      return res.statusCode >= 200 && res.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getDashboard() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/dashboard'), headers: h));
      if (res.statusCode == 401) return null;
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/profile'), headers: h));
      if (res.statusCode == 401) return null;
      return jsonDecode(res.body);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getStats() async {
    final dashboard = await getDashboard();
    if (dashboard == null) return null;
    return {
      'walletBalance': dashboard['walletBalance'],
      'totalEarnings': (dashboard['walletBalance'] ?? 0) + (dashboard['pendingEarnings'] ?? 0),
      'completedOrdersCount': dashboard['jobsDone'],
    };
  }

  Future<bool> updateLocation(double lat, double lng, [bool? isOnline]) async {
    try {
      if (isOnline != null) {
        await setOnline(isOnline);
      }
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/tech/location'),
            headers: h,
            body: jsonEncode({'lat': lat, 'lng': lng}),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> setOnline(bool isOnline) async {
    try {
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/tech/availability'),
            headers: h,
            body: jsonEncode({'isOnline': isOnline}),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getWallet() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/wallet'), headers: h));
      if (res.statusCode == 401) return null;
      return jsonDecode(res.body) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  Future<bool> requestWithdrawal({
    required double amount,
  }) async {
    try {
      final res = await _execute((h) => http.post(
            Uri.parse('$apiBaseUrl/payments/withdraw'),
            headers: h,
            body: jsonEncode({'amount': amount}),
          ));
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? email}) async {
    try {
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/auth/profile'),
            headers: h,
            body: jsonEncode({
              'name': name,
              'phone': phone,
              'email': email,
            }..removeWhere((k, v) => v == null)),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateBankDetails({required String accountName, required String accountNumber, required String ifscCode}) async {
    try {
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/tech/profile'),
            headers: h,
            body: jsonEncode({
              'bankDetails': {
                'accountName': accountName,
                'accountNumber': accountNumber,
                'ifscCode': ifscCode,
              }
            }),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getTechnicianEarnings() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/earnings'), headers: h));
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      return {};
    } catch (e) {
      return {};
    }
  }

  Future<List<dynamic>> getMonthlyEarnings() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/earnings/monthly'), headers: h));
      if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getMyJobs() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/tech/jobs?status=active'), headers: h));
      if (res.statusCode == 401) return [];
      return jsonDecode(res.body);
    } catch (e) {
      return [];
    }
  }

  Future<bool> startJob(String orderId) async {
    try {
      final res = await _execute((h) => http.post(Uri.parse('$apiBaseUrl/tech/jobs/$orderId/start'), headers: h));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateChecklist(String orderId, List<Map<String, dynamic>> checklist) async {
    try {
      final res = await _execute((h) => http.patch(
            Uri.parse('$apiBaseUrl/tech/jobs/$orderId/checklist'),
            headers: h,
            body: jsonEncode({'checklist': checklist}),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> completeJob(String orderId, String otp) async {
    try {
      final res = await _execute((h) => http.post(
            Uri.parse('$apiBaseUrl/orders/$orderId/complete'),
            headers: h,
            body: jsonEncode({'otp': otp}),
          ));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getMyNotifications() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/notifications/mine'), headers: h));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['data'] as List<dynamic>?) ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> markNotificationRead(String id) async {
    try {
      final res = await _execute((h) => http.patch(Uri.parse('$apiBaseUrl/notifications/mine/$id/read'), headers: h));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> markAllNotificationsRead() async {
    try {
      final res = await _execute((h) => http.patch(Uri.parse('$apiBaseUrl/notifications/mine/read-all'), headers: h));
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<dynamic>> getMySupportTickets() async {
    try {
      final res = await _execute((h) => http.get(Uri.parse('$apiBaseUrl/support/mine'), headers: h));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['data'] as List<dynamic>?) ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> createSupportTicket({
    required String subject,
    required String message,
    String category = 'general',
    String priority = 'medium',
    String? orderId,
  }) async {
    try {
      final res = await _execute((h) => http.post(
            Uri.parse('$apiBaseUrl/support'),
            headers: h,
            body: jsonEncode({
              'subject': subject,
              'message': message,
              'category': category,
              'priority': priority,
              ...?(orderId == null ? null : {'orderId': orderId}),
            }),
          ));
      return res.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> registerTechnician({
    required String name,
    required String email,
    required String password,
    required String phone,
    required List<String> skills,
    required String aadhaarNumber,
    required String aadhaarFrontPath,
    required String aadhaarBackPath,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$apiBaseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email.trim().toLowerCase(),
          'password': password,
          'phone': phone,
          'role': 'technician',
          'specialization': skills,
          'aadhaarNumber': aadhaarNumber,
          'aadhaarFront': aadhaarFrontPath,
          'aadhaarBack': aadhaarBackPath,
        }),
      );

      if (res.statusCode == 201 || res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final tokenStr = data['token']?.toString();
        if (tokenStr == null || tokenStr.isEmpty) {
          throw Exception('Invalid server response. Ensure your Serveo/Ngrok URL is correct.');
        }
        await saveToken(tokenStr);
        final refresh = data['refreshToken']?.toString();
        if (refresh != null && refresh.isNotEmpty) await _saveRefreshToken(refresh);
        return data;
      } else {
        try {
          final errorData = jsonDecode(res.body);
          throw Exception(errorData['message'] ?? 'Registration failed');
        } catch (e) {
          throw Exception('Registration failed (Code ${res.statusCode})');
        }
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> uploadProfilePhoto(String filePath) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final request = http.MultipartRequest('PUT', Uri.parse('$apiBaseUrl/technician-profile/profile/photo'));
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('photo', filePath));

      final streamed = await request.send();
      return streamed.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> uploadTechnicianKyc({
    required String aadhaarNumber,
    required XFile frontFile,
    required XFile backFile,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final request = http.MultipartRequest('PUT', Uri.parse('$apiBaseUrl/technician-profile/profile/kyc'));
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['aadharNumber'] = aadhaarNumber;

      final frontBytes = await frontFile.readAsBytes();
      final backBytes = await backFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('aadharFront', frontBytes, filename: frontFile.name));
      request.files.add(http.MultipartFile.fromBytes('aadharBack', backBytes, filename: backFile.name));

      final streamed = await request.send();
      final body = await streamed.stream.bytesToString();
      if (streamed.statusCode == 200) {
        return jsonDecode(body) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateTechnicianProfile({
    List<String>? specialization,
    String? experience,
    String? emoji,
    String? profilePhoto,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (specialization != null) body['specialization'] = specialization;
      if (experience != null) body['experience'] = experience;
      if (emoji != null) body['emoji'] = emoji;
      if (profilePhoto != null) body['profilePhoto'] = profilePhoto;

      final res = await _execute((h) => http.put(
            Uri.parse('$apiBaseUrl/technician-profile/profile/update'),
            headers: h,
            body: jsonEncode(body),
          ));
      if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateOrderStatus(String orderId, String status, {String? otp}) async {
    if (status == 'completed' && otp != null) {
      return completeJob(orderId, otp);
    } else if (status == 'in_progress' || status == 'started') {
      return startJob(orderId);
    }
    return false;
  }
}
