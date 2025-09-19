import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic>? decode(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      final payload = parts[1];
      // Add padding if needed
      final normalizedPayload = base64Url.normalize(payload);
      final decodedBytes = base64Url.decode(normalizedPayload);
      final decodedString = utf8.decode(decodedBytes);
      
      return json.decode(decodedString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  static bool isExpired(String token) {
    final decoded = decode(token);
    if (decoded == null) return true;

    final exp = decoded['exp'] as int?;
    if (exp == null) return true;

    final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiryDate);
  }

  static String? getUserId(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    // Based on your JWT structure
    return decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] as String?;
  }

  static String? getUserEmail(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    return decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] as String?;
  }

  static String? getUserName(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    return decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] as String?;
  }

  static DateTime? getExpiryDate(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    final exp = decoded['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }
}
