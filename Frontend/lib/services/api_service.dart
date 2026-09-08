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

  String _buildUrl(String endpoint) {
    if (endpoint.startsWith('http://') || endpoint.startsWith('https://')) {
      return endpoint;
    }
    if (endpoint == ApiConfig.chatEndpoint || endpoint == '/chat_with_bot') {
      return '${ApiConfig.serverBaseUrl}$endpoint';
    }
    return '${ApiConfig.baseUrl}$endpoint';
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? queryParams}) async {
    if (ApiConfig.useMockData) {
      throw ApiException('Mock data mode active', statusCode: 200);
    }

    try {
      final uri = Uri.parse(_buildUrl(endpoint)).replace(queryParameters: queryParams);
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
      final uri = Uri.parse(_buildUrl(endpoint));
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
    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      body = response.body;
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        return body;
      case 400:
        final msg = (body is Map && body.containsKey('detail'))
            ? body['detail']
            : (body is Map && body.containsKey('message') ? body['message'] : 'Bad Request');
        throw ApiException(msg.toString(), statusCode: 400);
      case 401:
        throw ApiException('Unauthorized access', statusCode: 401);
      case 403:
        throw ApiException('Forbidden request', statusCode: 403);
      case 404:
        final msg = (body is Map && body.containsKey('detail'))
            ? body['detail']
            : (body is Map && body.containsKey('message') ? body['message'] : 'Resource not found');
        throw ApiException(msg.toString(), statusCode: 404);
      case 429:
        throw ApiException('Too many requests. Please wait a moment.', statusCode: 429);
      case 500:
      default:
        final msg = (body is Map && body.containsKey('detail'))
            ? body['detail']
            : 'WeatherGPT server error (${response.statusCode})';
        throw ApiException(msg.toString(), statusCode: response.statusCode);
    }
  }
}
