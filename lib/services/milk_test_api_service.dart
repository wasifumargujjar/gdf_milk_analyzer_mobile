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
    final url =
        '/MilkTest/my-results?userId=$userId&page=$page&pageSize=$pageSize';
    print('MilkTestApiService: Calling $url');
    final response = await _apiService.get(url, requiresAuth: true);

    return MilkTestResultsResponse.fromJson(response);
  }

  /// Get a specific test result by ID
  Future<MilkTestResult> getTestResult(int id) async {
    final response = await _apiService.get('/MilkTest/$id', requiresAuth: true);

    return MilkTestResult.fromJson(response);
  }

  /// Schedule a new test using the ScheduleController endpoint
  /// Sends Date (yyyy-MM-dd), Time (HH:mm), VehicalId, TestTypeId and UserId
  Future<dynamic> scheduleTest({
    required String userId,
    required String date, // yyyy-MM-dd
    required String time, // HH:mm
    String? vehicalId,
    required String testTypeId,
  }) async {
    final body = {
      'UserId': userId,
      'Date': date,
      'Time': time,
      'VehicalId': vehicalId,
      'TestTypeId': testTypeId,
    };

    final response = await _apiService.post(
      '/api/Schedule',
      body,
      requiresAuth: true,
    );

    return response;
  }
}
