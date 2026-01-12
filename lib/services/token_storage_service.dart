import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';
  static const String _roleKey = 'role';
  static const String _userIdKey = 'userId';

  final FlutterSecureStorage _storage;

  TokenStorageService({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> saveUserInfo({
    required String username,
    required String email,
    required String role,
    String? userId,
  }) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _roleKey, value: role);
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId);
    }
  }

  Future<Map<String, String?>> getUserInfo() async {
    final username = await _storage.read(key: _usernameKey);
    final email = await _storage.read(key: _emailKey);
    final role = await _storage.read(key: _roleKey);
    final userId = await _storage.read(key: _userIdKey);

    return {
      'username': username,
      'email': email,
      'role': role,
      'userId': userId,
    };
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
