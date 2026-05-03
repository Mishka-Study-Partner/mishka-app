import 'package:dio/dio.dart';

import 'api_endpoints.dart';
import 'app_network_config.dart';
import 'token_storage.dart';

/// Singleton Dio with auth + [Accept-Language] headers.
class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  Dio? _dio;

  Dio get dio {
    final d = _dio;
    if (d == null) {
      throw StateError('DioClient.init() must be called after TokenStorage.init()');
    }
    return d;
  }

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Parse error envelopes for 4xx/5xx in [ApiService] instead of throwing here.
        validateStatus: (_) => true,
      ),
    );

    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['Accept-Language'] = AppNetworkConfig.acceptLanguage;
          final t = TokenStorage.token;
          if (t != null && t.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $t';
          } else {
            options.headers.remove('Authorization');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) => handler.next(response),
        onError: (err, handler) => handler.next(err),
      ),
    );
  }
}
