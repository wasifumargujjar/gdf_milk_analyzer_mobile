import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_user.dart';
import '../models/login_request.dart';
import '../models/register_model.dart';
import '../models/forgot_password_model.dart';
import '../models/reset_password_model.dart';
import 'service_providers.dart';
import '../services/api_service.dart';

/// Auth state that holds the current authenticated user
final authStateProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) {
      return AuthNotifier(ref);
    });

class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  final Ref _ref;

  AuthNotifier(this._ref) : super(const AsyncValue.loading()) {
    _checkAuthStatus();
  }

  /// Check if user is already logged in on app start
  Future<void> _checkAuthStatus() async {
    try {
      final tokenStorage = _ref.read(tokenStorageProvider);
      final hasToken = await tokenStorage.hasToken();

      if (hasToken) {
        final token = await tokenStorage.getToken();
        final userInfo = await tokenStorage.getUserInfo();

        if (token != null &&
            userInfo['username'] != null &&
            userInfo['email'] != null &&
            userInfo['role'] != null) {
          final userId =
              userInfo['userId'] ?? AuthUser.extractUserIdFromToken(token);
          state = AsyncValue.data(
            AuthUser(
              username: userInfo['username']!,
              email: userInfo['email']!,
              role: userInfo['role']!,
              token: token,
              userId: userId,
            ),
          );
        } else {
          state = const AsyncValue.data(null);
        }
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Login user
  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    try {
      final authService = _ref.read(authApiServiceProvider);
      final tokenStorage = _ref.read(tokenStorageProvider);

      final request = LoginRequest(username: username, password: password);
      final response = await authService.login(request);

      // Extract userId from token
      final userId = AuthUser.extractUserIdFromToken(response.token);
      print('Login: Extracted userId = $userId');

      // Save token and user info
      await tokenStorage.saveToken(response.token);
      await tokenStorage.saveUserInfo(
        username: response.username,
        email: response.email,
        role: response.role,
        userId: userId,
      );

      // Update state
      state = AsyncValue.data(
        AuthUser(
          username: response.username,
          email: response.email,
          role: response.role,
          token: response.token,
          userId: userId,
        ),
      );
    } on ApiException catch (e, stack) {
      state = AsyncValue.error(e.message, stack);
    } catch (e, stack) {
      state = AsyncValue.error('An unexpected error occurred', stack);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      final authService = _ref.read(authApiServiceProvider);
      final tokenStorage = _ref.read(tokenStorageProvider);

      // Call logout API to blacklist token
      try {
        await authService.logout();
      } catch (e) {
        // Continue with local logout even if API call fails
      }

      // Clear local storage
      await tokenStorage.clearAll();

      // Update state
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error('Logout failed', stack);
    }
  }

  /// Simple registration (AuthController - auto-confirms email)
  Future<String> registerSimple({
    required String username,
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final authService = _ref.read(authApiServiceProvider);

      await authService.registerSimple(
        username: username,
        email: email,
        fullName: fullName,
        password: password,
      );

      return 'Registration successful! You can now log in.';
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  /// Registration with email confirmation (AccountController)
  Future<String> registerWithConfirmation({
    required String email,
    required String fullName,
    required String password,
  }) async {
    try {
      final authService = _ref.read(authApiServiceProvider);

      final model = RegisterModel(
        fullName: fullName,
        email: email,
        password: password,
      );

      final response = await authService.registerWithConfirmation(model);
      return response['message'] ??
          'Registration successful! Please check your email.';
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Registration failed: $e';
    }
  }

  /// Confirm email
  Future<String> confirmEmail({
    required int userId,
    required String token,
  }) async {
    try {
      final authService = _ref.read(authApiServiceProvider);

      final response = await authService.confirmEmail(
        userId: userId,
        token: token,
      );

      return response['message'] ?? 'Email confirmed successfully!';
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Email confirmation failed: $e';
    }
  }

  /// Request password reset
  Future<String> forgotPassword(String email) async {
    try {
      final authService = _ref.read(authApiServiceProvider);

      final model = ForgotPasswordModel(email: email);
      final response = await authService.forgotPassword(model);

      return response['message'] ??
          'If your email is registered, you will receive a password reset link.';
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Request failed: $e';
    }
  }

  /// Reset password
  Future<String> resetPassword({
    required int userId,
    required String token,
    required String newPassword,
  }) async {
    try {
      final authService = _ref.read(authApiServiceProvider);

      final model = ResetPasswordModel(
        userId: userId,
        token: token,
        newPassword: newPassword,
      );

      final response = await authService.resetPassword(model);
      return response['message'] ?? 'Password has been reset successfully!';
    } on ApiException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'Password reset failed: $e';
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated {
    return state.value != null;
  }

  /// Get current user
  AuthUser? get currentUser {
    return state.value;
  }
}
