import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final DeepLinkService _deepLinkService = DeepLinkService();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _deepLinkService.initialize((Uri uri) {
      // Handle email confirmation links
      final confirmEmailData = DeepLinkService.parseConfirmEmailLink(uri);
      if (confirmEmailData != null) {
        final router = ref.read(routerProvider);
        router.go(
          '/confirm-email?userId=${confirmEmailData['userId']}&token=${confirmEmailData['token']}',
        );
        return;
      }

      // Handle password reset links
      final resetPasswordData = DeepLinkService.parseResetPasswordLink(uri);
      if (resetPasswordData != null) {
        final router = ref.read(routerProvider);
        router.go(
          '/reset-password?userId=${resetPasswordData['userId']}&token=${resetPasswordData['token']}',
        );
        return;
      }
    });
  }

  @override
  void dispose() {
    _deepLinkService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Milk Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
        ),
      ),
      routerConfig: router,
    );
  }
}
