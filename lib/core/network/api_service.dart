import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_envelope.dart';
import 'api_exception.dart';
import 'dio_client.dart';

/// Thin wrapper around Dio: parses success envelopes and maps errors to [ApiException].
class ApiService {
  ApiService([Dio? dio]) : _dio = dio ?? DioClient.instance.dio;

  final Dio _dio;

  Future<ApiEnvelope<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    _logRequest(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      expectedType: T.toString(),
    );
    try {
      final res = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(
        res,
        dataFromJson,
        method: 'GET',
        path: path,
      );
    } on DioException catch (e) {
      _logDioError(method: 'GET', path: path, error: e);
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    _logRequest(
      method: 'POST',
      path: path,
      data: data,
      expectedType: T.toString(),
    );
    try {
      final res = await _dio.post<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(
        res,
        dataFromJson,
        method: 'POST',
        path: path,
      );
    } on DioException catch (e) {
      _logDioError(method: 'POST', path: path, error: e);
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> put<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    _logRequest(
      method: 'PUT',
      path: path,
      data: data,
      expectedType: T.toString(),
    );
    try {
      final res = await _dio.put<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(
        res,
        dataFromJson,
        method: 'PUT',
        path: path,
      );
    } on DioException catch (e) {
      _logDioError(method: 'PUT', path: path, error: e);
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> patch<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    _logRequest(
      method: 'PATCH',
      path: path,
      data: data,
      expectedType: T.toString(),
    );
    try {
      final res = await _dio.patch<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(
        res,
        dataFromJson,
        method: 'PATCH',
        path: path,
      );
    } on DioException catch (e) {
      _logDioError(method: 'PATCH', path: path, error: e);
      throw _mapDio(e);
    }
  }

  /// Multipart file upload (e.g. avatar).
  Future<ApiEnvelope<T>> postMultipart<T>(
    String path, {
    required String filePath,
    String fileField = 'file',
    T Function(Object? json)? dataFromJson,
  }) async {
    _logRequest(method: 'POST(multipart)', path: path, expectedType: T.toString());
    try {
      final formData = FormData.fromMap({
        fileField: await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post<dynamic>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _handleResponse(res, dataFromJson, method: 'POST(multipart)', path: path);
    } on DioException catch (e) {
      _logDioError(method: 'POST(multipart)', path: path, error: e);
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> delete<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    _logRequest(
      method: 'DELETE',
      path: path,
      data: data,
      expectedType: T.toString(),
    );
    try {
      final res = await _dio.delete<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(
        res,
        dataFromJson,
        method: 'DELETE',
        path: path,
      );
    } on DioException catch (e) {
      _logDioError(method: 'DELETE', path: path, error: e);
      throw _mapDio(e);
    }
  }

  ApiEnvelope<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(Object? json)? dataFromJson,
    {
    required String method,
    required String path,
  }
  ) {
    _logRawResponse(
      method: method,
      path: path,
      statusCode: response.statusCode,
      body: response.data,
      expectedType: T.toString(),
    );
    final body = response.data;
    if (body is! Map) {
      throw ApiException(
        message: 'Invalid response body',
        error: 'INVALID_RESPONSE',
        statusCode: response.statusCode,
      );
    }
    final map = Map<String, dynamic>.from(body);
    final success = map['success'] as bool? ?? false;
    if (!success) {
      throw ApiException(
        message: _composeMessage(
          map['message'] as String? ?? 'Request failed',
          map['details'],
        ),
        error: map['error'] as String?,
        details: map['details'],
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode != null &&
        response.statusCode! >= 400) {
      throw ApiException(
        message: _composeMessage(
          map['message'] as String? ?? 'Request failed',
          map['details'],
        ),
        error: map['error'] as String?,
        details: map['details'],
        statusCode: response.statusCode,
      );
    }
    final envelope = ApiEnvelope.fromJson(map, dataFromJson);
    _logParsedEnvelope(
      method: method,
      path: path,
      statusCode: response.statusCode,
      envelope: envelope,
      expectedType: T.toString(),
    );
    return envelope;
  }

  ApiException _mapDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final success = map['success'] as bool?;
      if (success == false) {
        return ApiException(
          message: _composeMessage(
            map['message'] as String? ?? 'Request failed',
            map['details'],
          ),
          error: map['error'] as String?,
          details: map['details'],
          statusCode: e.response?.statusCode,
        );
      }
    }
    return ApiException(
      message: e.message ?? 'Network error',
      error: 'NETWORK_ERROR',
      statusCode: e.response?.statusCode,
      details: data,
    );
  }

  String _composeMessage(String baseMessage, Object? details) {
    if (details == null) return baseMessage;
    final trimmed = details.toString().trim();
    if (trimmed.isEmpty) return baseMessage;
    return '$baseMessage\n$trimmed';
  }

  void _logRequest({
    required String method,
    required String path,
    Object? data,
    Map<String, dynamic>? queryParameters,
    String? expectedType,
  }) {
    if (!kDebugMode) return;
    debugPrint('🌐 API REQUEST [$method] $path');
    if (expectedType != null) {
      debugPrint('   expected_response_type: $expectedType');
    }
    if (queryParameters != null && queryParameters.isNotEmpty) {
      debugPrint('   query: $queryParameters');
    }
    if (data != null) {
      debugPrint('   body: $data');
    }
  }

  void _logRawResponse({
    required String method,
    required String path,
    required int? statusCode,
    required Object? body,
    required String expectedType,
  }) {
    if (!kDebugMode) return;
    debugPrint('📥 API RESPONSE [$method] $path');
    debugPrint('   status: ${statusCode ?? 'unknown'}');
    debugPrint('   expected_response_type: $expectedType');
    debugPrint('   raw_body: $body');
  }

  void _logParsedEnvelope<T>({
    required String method,
    required String path,
    required int? statusCode,
    required ApiEnvelope<T> envelope,
    required String expectedType,
  }) {
    if (!kDebugMode) return;
    debugPrint('✅ API ENVELOPE [$method] $path');
    debugPrint('   status: ${statusCode ?? 'unknown'}');
    debugPrint('   success: ${envelope.success}');
    debugPrint('   message: ${envelope.message}');
    debugPrint('   error: ${envelope.error}');
    debugPrint('   details: ${envelope.details}');
    debugPrint('   parsed_data_type: $expectedType');
    debugPrint('   parsed_data: ${envelope.data}');
  }

  void _logDioError({
    required String method,
    required String path,
    required DioException error,
  }) {
    if (!kDebugMode) return;
    debugPrint('🛑 API DIO ERROR [$method] $path');
    debugPrint('   status: ${error.response?.statusCode}');
    debugPrint('   type: ${error.type}');
    debugPrint('   message: ${error.message}');
    debugPrint('   response_data: ${error.response?.data}');
  }
}
