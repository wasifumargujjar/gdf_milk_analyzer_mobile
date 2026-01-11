import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/milk_test_result.dart';
import '../providers/milk_test_provider.dart';

class TestsHistoryScreen extends ConsumerWidget {
  const TestsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testResults = ref.watch(milkTestResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tests History')),
      body: testResults.when(
        data: (results) {
          if (results.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.science_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('No test results yet'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final result = results[index];
              final dateTime = result.timestampUtc.toLocal();
              final dateStr = DateFormat('MMM dd, yyyy').format(dateTime);
              final timeStr = DateFormat('hh:mm a').format(dateTime);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    child: Icon(Icons.science, color: Theme.of(context).primaryColor),
                  ),
                  title: Text(result.rawLine ?? 'Sample #${result.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$dateStr • $timeStr'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/test-detail', extra: result);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
