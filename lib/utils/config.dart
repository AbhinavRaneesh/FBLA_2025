import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Global app configuration
class AppConfig {
  /// Toggle to switch between local SQLite and remote Mongo-backed API
  static const bool useRemoteDb = true; // set to true to use the cloud API

  /// Base URL for the backend API. Uses Android emulator loopback when needed.
  static String get baseUrl {
    // If API_BASE_URL is set via --dart-define, use it
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;

    // Production: use your deployed backend URL
    // TODO: Replace with your actual Render/Railway/Fly URL after deployment
    const productionUrl = 'https://your-backend.onrender.com';
    if (productionUrl != 'https://your-backend.onrender.com') {
      return productionUrl; // Use production URL if configured
    }

    // Development fallback: Web uses localhost
    if (kIsWeb) return 'http://localhost:3000';

    try {
      if (Platform.isAndroid) {
        // Special host to reach host machine from Android emulator
        return 'http://10.0.2.2:3000';
      }
    } catch (_) {
      // Platform may not be available in all contexts
    }

    return 'http://localhost:3000';
  }
}
