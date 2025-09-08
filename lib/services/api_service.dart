import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { get, post, put, delete, patch }

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException(this.message, {this.statusCode, this.responseData});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final http.Client _httpClient;

  ApiService({
    required this.baseUrl,
    this.defaultHeaders = const {'Content-Type': 'application/json'},
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<T> request<T>({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    try {
      // Build URL
      var uri = Uri.parse('$baseUrl$endpoint');
      if (queryParams != null) {
        uri = uri.replace(
            queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
      }

      // Prepare headers
      final requestHeaders = Map<String, String>.from(defaultHeaders);
      if (headers != null) {
        requestHeaders.addAll(headers);
      }

      // Prepare body
      var encodedBody = body != null ? jsonEncode(body) : null;

      // Make request
      http.Response response;
      switch (method) {
        case HttpMethod.get:
          response = await _httpClient
              .get(uri, headers: requestHeaders)
              .timeout(Duration(seconds: timeoutSeconds));
          break;
        case HttpMethod.post:
          response = await _httpClient
              .post(uri, headers: requestHeaders, body: encodedBody)
              .timeout(Duration(seconds: timeoutSeconds));
          break;
        case HttpMethod.put:
          response = await _httpClient
              .put(uri, headers: requestHeaders, body: encodedBody)
              .timeout(Duration(seconds: timeoutSeconds));
          break;
        case HttpMethod.delete:
          response = await _httpClient
              .delete(uri, headers: requestHeaders, body: encodedBody)
              .timeout(Duration(seconds: timeoutSeconds));
          break;
        case HttpMethod.patch:
          response = await _httpClient
              .patch(uri, headers: requestHeaders, body: encodedBody)
              .timeout(Duration(seconds: timeoutSeconds));
          break;
      }

      // Check response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success response
        if (response.body.isEmpty) {
          return parser(null);
        }
        
        final dynamic responseData = jsonDecode(response.body);
        return parser(responseData);
      } else {
        // Error response
        var responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
        throw ApiException(
          'Request failed with status ${response.statusCode}',
          statusCode: response.statusCode,
          responseData: responseBody,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        rethrow;
      }
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  void dispose() {
    _httpClient.close();
  }

  // Convenience methods
  Future<T> get<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.get,
      queryParams: queryParams,
      headers: headers,
      parser: parser,
      timeoutSeconds: timeoutSeconds,
    );
  }

  Future<T> post<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.post,
      queryParams: queryParams,
      headers: headers,
      body: body,
      parser: parser,
      timeoutSeconds: timeoutSeconds,
    );
  }

  Future<T> put<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.put,
      queryParams: queryParams,
      headers: headers,
      body: body,
      parser: parser,
      timeoutSeconds: timeoutSeconds,
    );
  }

  Future<T> delete<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.delete,
      queryParams: queryParams,
      headers: headers,
      body: body,
      parser: parser,
      timeoutSeconds: timeoutSeconds,
    );
  }

  Future<T> patch<T>({
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    dynamic body,
    required T Function(dynamic data) parser,
    int timeoutSeconds = 30,
  }) async {
    return request<T>(
      endpoint: endpoint,
      method: HttpMethod.patch,
      queryParams: queryParams,
      headers: headers,
      body: body,
      parser: parser,
      timeoutSeconds: timeoutSeconds,
    );
  }
}
