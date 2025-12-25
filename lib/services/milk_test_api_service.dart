import '../models/milk_test_result.dart';
import 'api_service.dart';

class MilkTestApiService {
  final ApiService _apiService;

  MilkTestApiService(this._apiService);

  /// Get current user's test results with pagination
  Future<MilkTestResultsResponse> getMyTestResults({
    required String userId,
    int page = 1,
    int pageSize = 10,
  }) async {
    final url = '/MilkTest/my-results?userId=$userId&page=$page&pageSize=$pageSize';
    print('MilkTestApiService: Calling $url');
    final response = await _apiService.get(
      url,
      requiresAuth: true,
    );

    return MilkTestResultsResponse.fromJson(response);
  }

  /// Get a specific test result by ID
  Future<MilkTestResult> getTestResult(int id) async {
    final response = await _apiService.get(
      '/MilkTest/$id',
      requiresAuth: true,
    );

    return MilkTestResult.fromJson(response);
  }
}
