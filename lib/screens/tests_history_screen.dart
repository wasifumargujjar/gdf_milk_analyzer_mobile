import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/milk_test_result.dart';
import '../providers/milk_test_provider.dart';

class TestsHistoryScreen extends ConsumerStatefulWidget {
  const TestsHistoryScreen({super.key});

  @override
  ConsumerState<TestsHistoryScreen> createState() => _TestsHistoryScreenState();
}

class _TestsHistoryScreenState extends ConsumerState<TestsHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'Newest';
  final Set<String> _statusFilters = {};

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testResultsAsync = ref.watch(milkTestResultsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tests History')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: testResultsAsync.when(
          data: (results) {
            if (results.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.science_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    const Text('No test results yet'),
                  ],
                ),
              );
            }

            // Apply filters
            final query = _searchController.text.trim().toLowerCase();
            List<MilkTestResult> filtered = results.where((r) {
              final date = r.timestampUtc.toLocal();
              if (_startDate != null && date.isBefore(_startDate!))
                return false;
              if (_endDate != null &&
                  date.isAfter(_endDate!.add(const Duration(days: 1))))
                return false;
              if (query.isNotEmpty) {
                final text = ((r.rawLine ?? '') + ' ' + r.id.toString())
                    .toLowerCase();
                if (!text.contains(query)) return false;
              }

              if (_statusFilters.isNotEmpty) {
                final status = ((r as dynamic).status?.toString() ?? 'UNKNOWN')
                    .toUpperCase();
                if (!_statusFilters.contains(status)) return false;
              }

              return true;
            }).toList();

            if (_sortBy == 'Newest') {
              filtered.sort((a, b) => b.timestampUtc.compareTo(a.timestampUtc));
            } else if (_sortBy == 'Oldest') {
              filtered.sort((a, b) => a.timestampUtc.compareTo(b.timestampUtc));
            }

            return Column(
              children: [
                // Search + filters
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          hintText: 'Search tests...',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _sortBy,
                      items: const [
                        DropdownMenuItem(
                          value: 'Newest',
                          child: Text('Newest'),
                        ),
                        DropdownMenuItem(
                          value: 'Oldest',
                          child: Text('Oldest'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _sortBy = v ?? 'Newest'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _pickStartDate,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _startDate == null
                            ? 'Start'
                            : DateFormat('MMM dd, yyyy').format(_startDate!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: _pickEndDate,
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _endDate == null
                            ? 'End'
                            : DateFormat('MMM dd, yyyy').format(_endDate!),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 6,
                      children: ['SCHEDULED', 'COMPLETED', 'FAILED'].map((s) {
                        final selected = _statusFilters.contains(s);
                        return FilterChip(
                          label: Text(s.toLowerCase()),
                          selected: selected,
                          onSelected: (v) => setState(
                            () => v
                                ? _statusFilters.add(s)
                                : _statusFilters.remove(s),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final result = filtered[index];
                      final dateTime = result.timestampUtc.toLocal();
                      final dateStr = DateFormat(
                        'MMM dd, yyyy',
                      ).format(dateTime);
                      final timeStr = DateFormat('hh:mm a').format(dateTime);

                      final status =
                          ((result as dynamic).status?.toString() ?? '')
                              .toUpperCase();

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: EdgeInsets.zero,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.12),
                            child: Icon(
                              Icons.science,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          title: Text(
                            result.rawLine ?? 'Sample #${result.id}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text('$dateStr • $timeStr'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (status.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                          onTap: () =>
                              context.push('/test-detail', extra: result),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
