import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../providers/milk_test_provider.dart';
import '../providers/service_providers.dart';
import '../services/milk_test_api_service.dart';
import '../providers/auth_provider.dart';

class ScheduleTestScreen extends ConsumerStatefulWidget {
  const ScheduleTestScreen({super.key});

  @override
  ConsumerState<ScheduleTestScreen> createState() => _ScheduleTestScreenState();
}

class _ScheduleTestScreenState extends ConsumerState<ScheduleTestScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedVehicleId;
  String? _selectedTestType;
  bool _submitting = false;

  final List<Map<String, String>> _vehicles = [
    {'id': 'veh-1', 'label': 'Vehicle A'},
    {'id': 'veh-2', 'label': 'Vehicle B'},
  ];

  final List<Map<String, String>> _testTypes = [
    {'value': 'ADULTRATION_TEST', 'label': 'Adultration Test'},
    {'value': 'MILK_ANALYSIS_TEST', 'label': 'Milk Analysis Test'},
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 0)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (_selectedTestType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a test type')),
      );
      return;
    }

    DateTime? scheduledAt;
    if (_selectedDate != null && _selectedTime != null) {
      scheduledAt = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );
    }

    setState(() => _submitting = true);

    try {
      final authUser = ref.read(authStateProvider).value;
      if (authUser == null) throw Exception('Not authenticated');

      final api = ref.read(milkTestApiServiceProvider);
      // Prepare date and time strings expected by ScheduleController
      String dateStr = '';
      String timeStr = '';
      if (scheduledAt != null) {
        final local = scheduledAt.toLocal();
        dateStr =
            '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
        timeStr =
            '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
      }

      await api.scheduleTest(
        userId: authUser.userId,
        date: dateStr,
        time: timeStr,
        vehicalId: _selectedVehicleId,
        testTypeId: _selectedTestType!,
      );

      // Refresh list so history shows new item
      await ref.read(milkTestResultsProvider.notifier).refresh();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Test has been scheduled successfully')),
      );
      context.go('/tests-history');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to schedule test: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _selectedDate == null
        ? 'Select date'
        : DateFormat('MMM dd, yyyy').format(_selectedDate!);
    final timeStr = _selectedTime == null
        ? 'Select time'
        : _selectedTime!.format(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Schedule Test')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Test Date & Time',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickDate,
                    child: Text(dateStr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _pickTime,
                    child: Text(timeStr),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Text('Vehicle', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedVehicleId,
              items: [
                const DropdownMenuItem(value: null, child: Text('No vehicle')),
                ..._vehicles.map(
                  (v) => DropdownMenuItem(
                    value: v['id'],
                    child: Text(v['label']!),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _selectedVehicleId = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const SizedBox(height: 16),
            Text(
              'Type of Test',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _selectedTestType,
              items: _testTypes
                  .map(
                    (t) => DropdownMenuItem(
                      value: t['value'],
                      child: Text(t['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedTestType = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Schedule Test'),
            ),
          ],
        ),
      ),
    );
  }
}
