import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'services/deep_link_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
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

    final primary = const Color(0xFF2563EB); // Indigo-blue
    final accent = const Color(0xFF06B6D4); // Teal

    return MaterialApp.router(
      title: 'Milk Analyzer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: accent,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(elevation: 0.5, centerTitle: false),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: primary,
          unselectedItemColor: Colors.grey[600],
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 0,
          ),
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.grey[900],
          displayColor: Colors.grey[900],
        ),
      ),
      routerConfig: router,
    );
  }
}
