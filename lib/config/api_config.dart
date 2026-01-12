class ApiConfig {
  // ⚠️ IMPORTANT: Update this with your actual backend API URL
  // Examples:
  // - Local backend: 'http://localhost:5000' or 'http://localhost:5284'
  // - Production: 'https://api.yourdomain.com'
  // - Test server: 'https://test-api.yourdomain.com'

  static const String baseUrl = 'https://gdfmilkanalyzer.com/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/login';
  static const String logoutEndpoint = '/auth/logout';
  static const String registerAuthEndpoint = '/auth/register';

  // Account endpoints
  static const String registerAccountEndpoint = '/account/register';
  static const String confirmEmailEndpoint = '/account/confirm-email';
  static const String forgotPasswordEndpoint = '/account/forgot-password';
  static const String resetPasswordEndpoint = '/account/reset-password';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
