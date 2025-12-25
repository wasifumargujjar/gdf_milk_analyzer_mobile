import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/milk_test_result.dart';
import '../services/milk_test_api_service.dart';
import 'service_providers.dart';
import 'auth_provider.dart';

final milkTestApiServiceProvider = Provider<MilkTestApiService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return MilkTestApiService(apiService);
});

final milkTestResultsProvider = StateNotifierProvider<MilkTestResultsNotifier, AsyncValue<List<MilkTestResult>>>((ref) {
  return MilkTestResultsNotifier(ref);
});

class MilkTestResultsNotifier extends StateNotifier<AsyncValue<List<MilkTestResult>>> {
  final Ref _ref;
  int _currentPage = 1;
  int _totalResults = 0;
  bool _hasMore = true;

  MilkTestResultsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadInitialResults();
  }

  Future<void> loadInitialResults() async {
    state = const AsyncValue.loading();
    _currentPage = 1;
    _hasMore = true;

    try {
      final service = _ref.read(milkTestApiServiceProvider);
      final authUser = _ref.read(authStateProvider).value;
      
      print('=== Loading Test Results ===');
      print('Auth user: ${authUser?.username}');
      print('User ID: ${authUser?.userId}');
      
      if (authUser == null) {
        print('No authenticated user, returning empty results');
        state = const AsyncValue.data([]);
        return;
      }

      print('Calling API with userId: ${authUser.userId}');
      final response = await service.getMyTestResults(
        userId: authUser.userId,
        page: 1,
        pageSize: 10,
      );
      print('API response: ${response.totalResults} results');
      print('===========================');

      _totalResults = response.totalResults;
      _hasMore = response.results.length < response.totalResults;

      state = AsyncValue.data(response.results);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentResults = state.value ?? [];
    if (currentResults.length >= _totalResults) {
      _hasMore = false;
      return;
    }

    try {
      final service = _ref.read(milkTestApiServiceProvider);
      final authUser = _ref.read(authStateProvider).value;
      
      if (authUser == null) return;
      
      _currentPage++;
      
      final response = await service.getMyTestResults(
        userId: authUser.userId,
        page: _currentPage,
        pageSize: 10,
      );

      final newResults = [...currentResults, ...response.results];
      _hasMore = newResults.length < response.totalResults;

      state = AsyncValue.data(newResults);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    await loadInitialResults();
  }

  bool get hasMore => _hasMore;
  int get totalResults => _totalResults;
}
