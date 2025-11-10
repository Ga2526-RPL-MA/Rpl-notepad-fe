import 'package:jwt_decoder/jwt_decoder.dart';

class JwtHelper {
  static Map<String, dynamic>? decodeToken(String token) {
    try {
      if (token.isEmpty) return null;
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  static String? getEmail(String token) {
    final payload = decodeToken(token);
    return payload?['email'] as String?;
  }

  static String? getName(String token) {
    final payload = decodeToken(token);
    return payload?['name'] as String?;
  }

  static int? getUserId(String token) {
    final payload = decodeToken(token);
    if (payload == null) return null;
    final dynamic raw = payload['id'] ?? payload['userId'] ?? payload['sub'];
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final parsed = int.tryParse(raw);
      return parsed;
    }
    return null;
  }
}
