import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';

MqttClient setupMqttClient(String host, String identifier, int port) {
  final protocol = port == 443 ? 'wss' : 'ws';
  final client = MqttBrowserClient('$protocol://$host:$port/mqtt', identifier);
  client.port = port;
  client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;
  return client;
}
