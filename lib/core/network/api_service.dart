import 'package:dio/dio.dart';

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
    try {
      final res = await _dio.get<dynamic>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(res, dataFromJson);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> post<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    try {
      final res = await _dio.post<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(res, dataFromJson);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> put<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    try {
      final res = await _dio.put<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(res, dataFromJson);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  Future<ApiEnvelope<T>> delete<T>(
    String path, {
    Object? data,
    T Function(Object? json)? dataFromJson,
    Options? options,
  }) async {
    try {
      final res = await _dio.delete<dynamic>(
        path,
        data: data,
        options: options,
      );
      return _handleResponse(res, dataFromJson);
    } on DioException catch (e) {
      throw _mapDio(e);
    }
  }

  ApiEnvelope<T> _handleResponse<T>(
    Response<dynamic> response,
    T Function(Object? json)? dataFromJson,
  ) {
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
        message: map['message'] as String? ?? 'Request failed',
        error: map['error'] as String?,
        details: map['details'],
        statusCode: response.statusCode,
      );
    }
    if (response.statusCode != null &&
        response.statusCode! >= 400) {
      throw ApiException(
        message: map['message'] as String? ?? 'Request failed',
        error: map['error'] as String?,
        details: map['details'],
        statusCode: response.statusCode,
      );
    }
    return ApiEnvelope.fromJson(map, dataFromJson);
  }

  ApiException _mapDio(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final success = map['success'] as bool?;
      if (success == false) {
        return ApiException(
          message: map['message'] as String? ?? 'Request failed',
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
}
