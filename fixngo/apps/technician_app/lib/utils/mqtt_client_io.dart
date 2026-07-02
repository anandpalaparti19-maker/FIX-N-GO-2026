import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

MqttClient setupMqttClient(String host, String identifier, int port) {
  final protocol = port == 443 ? 'wss' : 'ws';
  final client = MqttServerClient.withPort('$protocol://$host/mqtt', identifier, port);
  client.useWebSocket = true;
  if (port == 443) {
    client.secure = true;
  }
  return client;
}
