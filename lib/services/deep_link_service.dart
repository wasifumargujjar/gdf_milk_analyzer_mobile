import 'dart:async';
import 'package:app_links/app_links.dart';

class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _linkSubscription;

  /// Initialize deep link handling
  Future<void> initialize(Function(Uri) onLink) async {
    // Handle initial link if app was opened via deep link
    try {
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        onLink(initialLink);
      }
    } catch (e) {
      // Handle error
    }

    // Handle links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        onLink(uri);
      },
      onError: (err) {
        // Handle error
      },
    );
  }

  /// Dispose the service
  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Parse email confirmation link
  /// Expected format: yourapp://confirm-email?userId=123&token=abc123
  static Map<String, dynamic>? parseConfirmEmailLink(Uri uri) {
    if (uri.host == 'confirm-email' || uri.path.contains('confirm-email')) {
      final userId = uri.queryParameters['userId'];
      final token = uri.queryParameters['token'];

      if (userId != null && token != null) {
        return {'userId': int.tryParse(userId), 'token': token};
      }
    }
    return null;
  }

  /// Parse password reset link
  /// Expected format: yourapp://reset-password?userId=123&token=abc123
  static Map<String, dynamic>? parseResetPasswordLink(Uri uri) {
    if (uri.host == 'reset-password' || uri.path.contains('reset-password')) {
      final userId = uri.queryParameters['userId'];
      final token = uri.queryParameters['token'];

      if (userId != null && token != null) {
        return {'userId': int.tryParse(userId), 'token': token};
      }
    }
    return null;
  }
}
