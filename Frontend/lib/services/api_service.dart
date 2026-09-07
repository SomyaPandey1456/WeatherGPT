import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    if (ApiConfig.useMockData) {
      throw ApiException('Mock data mode active', statusCode: 200);
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(queryParameters: queryParams);
      final response = await _client
          .get(uri, headers: ApiConfig.defaultHeaders)
          .timeout(const Duration(milliseconds: ApiConfig.requestTimeoutMs));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your network connection.', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to connect to WeatherGPT server: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    if (ApiConfig.useMockData) {
      throw ApiException('Mock data mode active', statusCode: 200);
    }

    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final response = await _client
          .post(
            uri,
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(milliseconds: ApiConfig.requestTimeoutMs));

      return _processResponse(response);
    } on TimeoutException {
      throw ApiException('Request timed out. Please check your network connection.', statusCode: 408);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to send request to WeatherGPT server: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    final body = jsonDecode(response.body);

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        throw ApiException(body['message'] ?? 'Bad Request', statusCode: 400);
      case 401:
        throw ApiException('Unauthorized access', statusCode: 401);
      case 403:
        throw ApiException('Forbidden request', statusCode: 403);
      case 404:
        throw ApiException(body['message'] ?? 'Resource not found', statusCode: 404);
      case 429:
        throw ApiException('Too many requests. Please wait a moment.', statusCode: 429);
      case 500:
      default:
        throw ApiException('WeatherGPT server error (${response.statusCode})', statusCode: response.statusCode);
    }
  }
}
