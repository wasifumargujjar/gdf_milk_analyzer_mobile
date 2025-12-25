import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_storage_service.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  final TokenStorageService _tokenStorage;
  final http.Client _client;

  ApiService({
    required TokenStorageService tokenStorage,
    http.Client? client,
  })  : _tokenStorage = tokenStorage,
        _client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({bool includeAuth = false}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }
      return json.decode(response.body);
    } else {
      String errorMessage = 'Request failed';
      
      try {
        final errorBody = json.decode(response.body);
        if (errorBody is Map) {
          errorMessage = errorBody['message'] ?? 
                        errorBody['error'] ?? 
                        errorMessage;
          
          // Handle validation errors
          if (errorBody['errors'] != null) {
            errorMessage = errorBody['errors'].toString();
          }
        }
      } catch (e) {
        errorMessage = response.body.isNotEmpty 
            ? response.body 
            : 'Request failed with status ${response.statusCode}';
      }

      throw ApiException(errorMessage, response.statusCode);
    }
  }

  Future<dynamic> get(String endpoint, {bool requiresAuth = false}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await _client
          .get(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Service unavailable');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> post(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await _client
          .post(
            url,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectionTimeout);

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Service unavailable');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> put(
    String endpoint,
    dynamic body, {
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await _client
          .put(
            url,
            headers: headers,
            body: json.encode(body),
          )
          .timeout(ApiConfig.connectionTimeout);

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Service unavailable');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }

  Future<dynamic> delete(String endpoint, {bool requiresAuth = false}) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final headers = await _getHeaders(includeAuth: requiresAuth);

      final response = await _client
          .delete(url, headers: headers)
          .timeout(ApiConfig.connectionTimeout);

      return await _handleResponse(response);
    } on SocketException {
      throw ApiException('No internet connection');
    } on HttpException {
      throw ApiException('Service unavailable');
    } on FormatException {
      throw ApiException('Invalid response format');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('An unexpected error occurred: $e');
    }
  }
}
