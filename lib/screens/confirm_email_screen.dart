import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class ConfirmEmailScreen extends ConsumerStatefulWidget {
  final int userId;
  final String token;

  const ConfirmEmailScreen({
    super.key,
    required this.userId,
    required this.token,
  });

  @override
  ConsumerState<ConfirmEmailScreen> createState() => _ConfirmEmailScreenState();
}

class _ConfirmEmailScreenState extends ConsumerState<ConfirmEmailScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _confirmEmail();
  }

  Future<void> _confirmEmail() async {
    try {
      final message = await ref
          .read(authStateProvider.notifier)
          .confirmEmail(userId: widget.userId, token: widget.token);

      if (mounted) {
        setState(() {
          _successMessage = message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Confirmation')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading) ...[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  const Text(
                    'Confirming your email...',
                    style: TextStyle(fontSize: 16),
                  ),
                ] else if (_successMessage != null) ...[
                  const Icon(Icons.check_circle, color: Colors.green, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Success!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _successMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ] else if (_errorMessage != null) ...[
                  const Icon(Icons.error, color: Colors.red, size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Confirmation Failed',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () {
                      context.go('/login');
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                    child: const Text('Go to Login'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
