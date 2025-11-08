import 'package:flutter/foundation.dart' show kDebugMode;

class AppConfig {
  // Base URL for the API
  static const String _productionUrl = "https://rpl-notepad-be.vercel.app";
  static const String _developmentUrl = "https://rpl-notepad-be.vercel.app";

  // Use development URL in debug mode, production otherwise
  static String get baseURL => kDebugMode ? _developmentUrl : _productionUrl;

  // Get the actual API base URL (without proxy)
  static String get apiBaseURL => _productionUrl;

  // Check if running with proxy
  static bool get isUsingProxy => kDebugMode && baseURL == _developmentUrl;
}
