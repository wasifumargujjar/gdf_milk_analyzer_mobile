import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/login_response.dart';
import '../models/register_model.dart';
import '../models/forgot_password_model.dart';
import '../models/reset_password_model.dart';
import 'api_service.dart';

class AuthApiService {
  final ApiService _apiService;

  AuthApiService(this._apiService);

  /// Login via AuthController
  Future<LoginResponse> login(LoginRequest request) async {
    final response = await _apiService.post(
      ApiConfig.loginEndpoint,
      request.toJson(),
    );

    return LoginResponse.fromJson(response);
  }

  /// Logout via AuthController
  Future<void> logout() async {
    await _apiService.post(
      ApiConfig.logoutEndpoint,
      {},
      requiresAuth: true,
    );
  }

  /// Simple registration via AuthController (auto-confirms email)
  Future<Map<String, dynamic>> registerSimple({
    required String username,
    required String email,
    required String fullName,
    required String password,
  }) async {
    final response = await _apiService.post(
      ApiConfig.registerAuthEndpoint,
      {
        'username': username,
        'email': email,
        'fullName': fullName,
        'passwordHash': password,
        'role': 'User',
      },
    );

    return response as Map<String, dynamic>;
  }

  /// Registration via AccountController (requires email confirmation)
  Future<Map<String, dynamic>> registerWithConfirmation(
    RegisterModel model,
  ) async {
    final response = await _apiService.post(
      ApiConfig.registerAccountEndpoint,
      model.toJson(),
    );

    return response as Map<String, dynamic>;
  }

  /// Confirm email via AccountController
  Future<Map<String, dynamic>> confirmEmail({
    required int userId,
    required String token,
  }) async {
    final response = await _apiService.get(
      '${ApiConfig.confirmEmailEndpoint}?userId=$userId&token=$token',
    );

    return response as Map<String, dynamic>;
  }

  /// Request password reset via AccountController
  Future<Map<String, dynamic>> forgotPassword(
    ForgotPasswordModel model,
  ) async {
    final response = await _apiService.post(
      ApiConfig.forgotPasswordEndpoint,
      model.toJson(),
    );

    return response as Map<String, dynamic>;
  }

  /// Reset password via AccountController
  Future<Map<String, dynamic>> resetPassword(
    ResetPasswordModel model,
  ) async {
    final response = await _apiService.post(
      ApiConfig.resetPasswordEndpoint,
      model.toJson(),
    );

    return response as Map<String, dynamic>;
  }
}
