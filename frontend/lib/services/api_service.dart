import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // 192.168.31.122 is your host PC's Wi-Fi IP address on the local network.
  // This allows physical Android phones (e.g. connected via USB / Wi-Fi) to reach FastAPI.
  static String get defaultHost {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    }
    try {
      if (Platform.isAndroid) {
        // Works for physical phone on local Wi-Fi:
        return 'http://192.168.31.122:8000';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000';
  }

  static String _baseUrl = defaultHost;

  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    if (url.endsWith('/')) {
      _baseUrl = url.substring(0, url.length - 1);
    } else {
      _baseUrl = url;
    }
  }

  /// Ping the backend health endpoint
  static Future<bool> checkConnection([String? testUrl]) async {
    final target = testUrl ?? _baseUrl;
    try {
      final response = await http
          .get(Uri.parse('$target/health'))
          .timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
