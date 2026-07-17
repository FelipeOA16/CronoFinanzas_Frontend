import 'package:flutter/foundation.dart' show kIsWeb;

class Env {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );
  static const String _lanBaseUrl = 'http://192.168.1.41:8050';
  static const String _webBaseUrl = 'http://localhost:8050';
  static const String prodBaseUrl = 'https://api.production.com';

  /// En Web usa localhost; en Android/iOS usa la IP de la LAN.
  static String get baseUrl => _configuredBaseUrl.isNotEmpty
      ? _configuredBaseUrl
      : kIsWeb
      ? _webBaseUrl
      : _lanBaseUrl;
}
