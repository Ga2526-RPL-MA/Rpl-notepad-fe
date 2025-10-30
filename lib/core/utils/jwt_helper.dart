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
}
