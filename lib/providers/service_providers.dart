import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/token_storage_service.dart';
import '../services/api_service.dart';
import '../services/auth_api_service.dart';

// Token Storage Provider
final tokenStorageProvider = Provider<TokenStorageService>((ref) {
  return TokenStorageService();
});

// API Service Provider
final apiServiceProvider = Provider<ApiService>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiService(tokenStorage: tokenStorage);
});

// Auth API Service Provider
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthApiService(apiService);
});
