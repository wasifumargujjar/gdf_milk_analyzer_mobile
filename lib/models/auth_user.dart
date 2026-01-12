import 'dart:convert';

/// Represents the currently authenticated user's state
class AuthUser {
  final String username;
  final String email;
  final String role;
  final String token;
  final String userId;

  AuthUser({
    required this.username,
    required this.email,
    required this.role,
    required this.token,
    required this.userId,
  });

  /// Extract userId from JWT token
  static String extractUserIdFromToken(String token) {
    try {
      print('=== JWT Token Extraction Debug ===');
      print('Token length: ${token.length}');
      print(
        'Token (first 50 chars): ${token.substring(0, token.length > 50 ? 50 : token.length)}',
      );

      // JWT tokens have 3 parts separated by dots: header.payload.signature
      final parts = token.split('.');
      if (parts.length != 3) {
        print(
          'ERROR: Token does not have 3 parts. Parts count: ${parts.length}',
        );
        return '';
      }

      // Decode the payload (second part)
      final payload = parts[1];
      // Add padding if needed for base64 decoding
      var normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      print('Decoded JWT payload string: $decoded');

      final Map<String, dynamic> payloadMap = json.decode(decoded);
      print('Parsed payload map: $payloadMap');
      print('Available claim keys: ${payloadMap.keys.toList()}');

      // Try different claim names
      final claimNames = [
        'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier',
        'nameid',
        'sub',
        'userId',
        'id',
        'user_id',
      ];

      for (var claimName in claimNames) {
        if (payloadMap.containsKey(claimName)) {
          final value = payloadMap[claimName];
          print(
            'Found claim "${claimName}": $value (type: ${value.runtimeType})',
          );

          // Handle array values - take the first element
          if (value is List && value.isNotEmpty) {
            final userId = value[0].toString();
            print('Extracted userId from array[0]: $userId');
            print('==================================');
            return userId;
          } else {
            final userId = value?.toString() ?? '';
            print('Extracted userId as string: $userId');
            print('==================================');
            return userId;
          }
        }
      }

      print('ERROR: userId not found in any known claim');
      print('==================================');
      return '';
    } catch (e, stackTrace) {
      print('ERROR extracting userId from token: $e');
      print('Stack trace: $stackTrace');
      print('==================================');
      return '';
    }
  }
}
