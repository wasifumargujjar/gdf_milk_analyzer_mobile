import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/register_simple_screen.dart';
import '../screens/register_with_confirmation_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/reset_password_screen.dart';
import '../screens/confirm_email_screen.dart';
import '../screens/home_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/milk_test_detail_screen.dart';
import '../screens/tests_history_screen.dart';
import '../screens/schedule_test_screen.dart';
import '../models/milk_test_result.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = authState.value != null;
      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register-simple' ||
          state.matchedLocation == '/register-with-confirmation' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password') ||
          state.matchedLocation.startsWith('/confirm-email');

      // If user is not authenticated and trying to access protected routes
      if (!isAuthenticated && !isLoggingIn) {
        return '/login';
      }

      // If user is authenticated and trying to access auth screens
      if (isAuthenticated && isLoggingIn) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register-simple',
        builder: (context, state) => const RegisterSimpleScreen(),
      ),
      GoRoute(
        path: '/register-with-confirmation',
        builder: (context, state) =>
            const RegisterWithConfirmationScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          final userId = int.tryParse(state.uri.queryParameters['userId'] ?? '');
          final token = state.uri.queryParameters['token'];

          if (userId == null || token == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Invalid reset password link'),
              ),
            );
          }

          return ResetPasswordScreen(userId: userId, token: token);
        },
      ),
      GoRoute(
        path: '/confirm-email',
        builder: (context, state) {
          final userId = int.tryParse(state.uri.queryParameters['userId'] ?? '');
          final token = state.uri.queryParameters['token'];

          if (userId == null || token == null) {
            return Scaffold(
              appBar: AppBar(title: const Text('Error')),
              body: const Center(
                child: Text('Invalid confirmation link'),
              ),
            );
          }

          return ConfirmEmailScreen(userId: userId, token: token);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/tests-history',
        builder: (context, state) => const TestsHistoryScreen(),
      ),
      GoRoute(
        path: '/schedule-tests',
        builder: (context, state) => const ScheduleTestScreen(),
      ),
      GoRoute(
        path: '/test-detail',
        builder: (context, state) {
          final testResult = state.extra as MilkTestResult;
          return MilkTestDetailScreen(testResult: testResult);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Page not found: ${state.matchedLocation}'),
      ),
    ),
  );
});
