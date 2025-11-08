import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rpl_notepad_fe/core/utils/jwt_helper.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static String? _token;
  static SharedPreferences? _prefs;
  static Completer<void>? _initCompleter;
  static bool get isInitialized => _initCompleter?.isCompleted ?? false;

  // Init
  static Future<void> init() async {
    if (isInitialized) return;
    
    _initCompleter = Completer<void>();
    
    try {
      WidgetsFlutterBinding.ensureInitialized();
      try {
        _prefs = await SharedPreferences.getInstance();
      } catch (error) {
        debugPrint('Error getting SharedPreferences: $error');
        _prefs = null;
      }
      
      if (_prefs != null) {
        _token = _prefs!.getString(_tokenKey);
        debugPrint('AuthService initialized. Token exists: ${_token != null}');
      } else {
        debugPrint('Warning: SharedPreferences is null');
      }
      
      _initCompleter!.complete();
    } catch (e, stackTrace) {
      debugPrint('Error initializing AuthService: $e');
      debugPrint('Stack trace: $stackTrace');
      _token = null;
      _initCompleter!.completeError(e, stackTrace);
    }
  }

  static Future<void> _ensureInitialized() async {
    if (!isInitialized) {
      await _initCompleter?.future.catchError((_) {});
    }
  }

  // Save token
  static Future<void> saveToken(String token) async {
    try {
      await _ensureInitialized();
      _token = token;
      
      if (_prefs != null) {
        await _prefs!.setString(_tokenKey, token);
        debugPrint('Token saved successfully');
      } else {
        debugPrint('Warning: Cannot save token - SharedPreferences is null');
      }
    } catch (e, stackTrace) {
      debugPrint('Error saving token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Clear token
  static Future<void> clearToken() async {
    try {
      await _ensureInitialized();
      _token = null;
      
      if (_prefs != null) {
        await _prefs!.remove(_tokenKey);
        debugPrint('Token cleared successfully');
      } else {
        debugPrint('Warning: Cannot clear token - SharedPreferences is null');
      }
    } catch (e, stackTrace) {
      debugPrint('Error clearing token: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Get  token
  static String? get token {
    if (!isInitialized) {
      debugPrint('Warning: Accessing token before AuthService is initialized');
      return null;
    }
    return _token;
  }

  // Check user logged in
  static bool get isLoggedIn => token != null;

  // Get email from token
  static String? get userEmail {
    final currentToken = token;
    return currentToken != null ? JwtHelper.getEmail(currentToken) : null;
  }

  // Get username from token
  static String? get userName {
    final currentToken = token;
    return currentToken != null ? JwtHelper.getName(currentToken) : null;
  }
}
