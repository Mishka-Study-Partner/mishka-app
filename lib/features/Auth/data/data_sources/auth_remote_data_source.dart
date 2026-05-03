import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/network/token_storage.dart';

import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiService _api;

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final env = await _api.post<AuthResponseModel>(
      ApiEndpoints.authLogin,
      data: {
        'email': email,
        'password': password,
      },
      dataFromJson: (raw) =>
          AuthResponseModel.fromJson(raw! as Map<String, dynamic>),
    );
    final data = env.data;
    if (data == null) {
      throw ApiException(message: 'Empty auth data', error: 'INVALID_RESPONSE');
    }
    await TokenStorage.saveToken(data.accessToken);
    return data;
  }

  Future<AuthResponseModel> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required bool agreeTerms,
    String? phoneNumber,
    String? countryCode,
  }) async {
    final env = await _api.post<AuthResponseModel>(
      ApiEndpoints.authRegister,
      data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'agreeTerms': agreeTerms,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (countryCode != null) 'countryCode': countryCode,
      },
      dataFromJson: (raw) =>
          AuthResponseModel.fromJson(raw! as Map<String, dynamic>),
    );
    final data = env.data;
    if (data == null) {
      throw ApiException(message: 'Empty auth data', error: 'INVALID_RESPONSE');
    }
    await TokenStorage.saveToken(data.accessToken);
    return data;
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final env = await _api.get<UserModel>(
        ApiEndpoints.authMe,
        dataFromJson: (raw) {
          final map = raw! as Map<String, dynamic>;
          final user = map['user'];
          if (user is! Map<String, dynamic>) {
            throw const FormatException('Missing user in /auth/me data');
          }
          return UserModel.fromJson(user);
        },
      );
      final user = env.data;
      if (user == null) {
        throw ApiException(message: 'Empty user data', error: 'INVALID_RESPONSE');
      }
      return user;
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) {
        await TokenStorage.clearToken();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearToken();
  }

  bool _isAuthFailure(ApiException e) {
    final code = e.error;
    return e.statusCode == 401 ||
        code == 'AUTH_INVALID_TOKEN' ||
        code == 'AUTH_MISSING_TOKEN';
  }
}
