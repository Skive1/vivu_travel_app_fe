import 'dart:convert';

class JwtDecoder {
  // Standard JWT claim keys từ payload bạn cung cấp
  static const String _nameIdentifierClaim = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier';
  static const String _emailClaim = 'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress';

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

    // So sánh UTC với UTC để tránh lỗi timezone
    final expiryDateUTC = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
    final nowUTC = DateTime.now().toUtc();
    
    return nowUTC.isAfter(expiryDateUTC);
  }

  static String? getUserId(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    return decoded[_nameIdentifierClaim] as String?;
  }

  static String? getUserEmail(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    return decoded[_emailClaim] as String?;
  }

  static String? getUserName(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    // Fallback to email nếu không có name claim
    return decoded['name'] as String? ?? 
           decoded[_emailClaim] as String?;
  }

  static DateTime? getExpiryDate(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    final exp = decoded['exp'] as int?;
    if (exp == null) return null;

    // Trả về UTC time để consistent với isExpired
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
  }

  static Duration? getTimeUntilExpiry(String token) {
    final expiryDate = getExpiryDate(token);
    if (expiryDate == null) return null;

    final nowUTC = DateTime.now().toUtc();
    if (nowUTC.isAfter(expiryDate)) return Duration.zero;

    return expiryDate.difference(nowUTC);
  }

  // Validate token structure và required claims
  static bool isValidTokenStructure(String token) {
    final decoded = decode(token);
    if (decoded == null) return false;

    // Check required claims theo payload structure
    final hasUserId = decoded[_nameIdentifierClaim] != null;
    final hasEmail = decoded[_emailClaim] != null;
    final hasExp = decoded['exp'] != null;
    final hasIss = decoded['iss'] == 'TravelPlannerAPI';
    final hasAud = decoded['aud'] == 'TravelPlannerClient';

    return hasUserId && hasEmail && hasExp && hasIss && hasAud;
  }

  // Get all user claims from token
  static Map<String, dynamic>? getUserClaims(String token) {
    final decoded = decode(token);
    if (decoded == null) return null;

    return {
      'userId': decoded[_nameIdentifierClaim],
      'email': decoded[_emailClaim],
      'exp': decoded['exp'],
      'iss': decoded['iss'],
      'aud': decoded['aud'],
    };
  }
}
