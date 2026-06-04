import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null && _token!.isNotEmpty) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post('/api/auth/login', {'email': email, 'password': password});
    _token = data['token'] as String?;
    return data;
  }

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final data = await _post('/api/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    _token = data['token'] as String?;
    return data;
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

  Future<List<dynamic>> getTechnicians() async => _getList('/api/technician');

  Future<List<dynamic>> getOrders() async => _getList('/api/orders');

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
    });
  }

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers);
    return _decode(res);
  }

  Future<List<dynamic>> _getList(String path) async {
    final res = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers);
    final data = _decode(res);
    if (data is List) return data;
    return [];
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _decode(res);
  }

  dynamic _decode(http.Response res) {
    // Returns Map, List, or other JSON value
    final body = res.body.isEmpty ? '{}' : res.body;
    final decoded = jsonDecode(body);
    if (res.statusCode >= 400) {
      final msg = decoded is Map && decoded['message'] != null
          ? decoded['message'].toString()
          : 'Request failed (${res.statusCode})';
      throw ApiException(msg);
    }
    return decoded;
  }
}
