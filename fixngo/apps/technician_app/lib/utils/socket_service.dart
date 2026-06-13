import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  late io.Socket socket;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  factory SocketService() {
    return _instance;
  }

  SocketService._internal();

  Future<void> connect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) return;
      final serverUrl = ApiConfig.baseUrl;

      socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .build(),
      );

      socket.onConnect((_) {
        debugPrint('Technician Socket connected');
        _isConnected = true;
        socket.emit('user-online', {});
      });

      socket.onDisconnect((_) {
        debugPrint('Technician Socket disconnected');
        _isConnected = false;
      });

      socket.onConnectError((error) {
        debugPrint('Technician Connection error: $error');
      });

      socket.onError((error) {
        debugPrint('Technician Socket error: $error');
      });

      socket.connect();
    } catch (e) {
      debugPrint('Error connecting to technician socket: $e');
    }
  }

  void disconnect() {
    if (_isConnected) {
      socket.disconnect();
    }
  }

  // Listen to order updates
  void onOrderUpdated(Function(dynamic) callback) {
    socket.on('order-updated', (data) {
      callback(data);
    });
  }

  // Emit technician location
  void emitLocationUpdate(String orderId, double lat, double lng) {
    if (_isConnected) {
      socket.emit('location-update', {
        'orderId': orderId,
        'lat': lat,
        'lng': lng,
      });
    }
  }

  // Emit order status update
  void updateOrderStatus(String orderId, String status, String? note) {
    if (_isConnected) {
      socket.emit('order-status-update', {
        'orderId': orderId,
        'status': status,
        'note': note,
      });
    }
  }

  // Remove listener
  void off(String event) {
    socket.off(event);
  }
}
