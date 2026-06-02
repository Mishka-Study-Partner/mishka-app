import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/network/token_storage.dart';

import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';

import '../models/auth_me_data.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._api);

  final ApiService _api;

  Future<AuthResponseModel> login({
    String? email,
    String? phoneNumber,
    String? countryCode,
    required String password,
    bool rememberMe = false,
  }) async {
    if ((email == null || email.trim().isEmpty) &&
        (phoneNumber == null || phoneNumber.trim().isEmpty)) {
      throw ApiException(
        message: 'Email or phone number is required',
        error: 'VALIDATION_ERROR',
      );
    }
    final env = await _api.post<AuthResponseModel>(
      ApiEndpoints.authLogin,
      data: {
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
        if (countryCode != null && countryCode.trim().isNotEmpty)
          'countryCode': countryCode.trim(),
        'password': password,
        'rememberMe': rememberMe,
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
    String? educationStatus,
    String? educationOtherDetail,
    String? signupOtp,
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
        if (educationStatus != null && educationStatus.isNotEmpty)
          'educationStatus': educationStatus,
        if (educationStatus == 'other' &&
            educationOtherDetail != null &&
            educationOtherDetail.trim().isNotEmpty)
          'educationOtherDetail': educationOtherDetail.trim(),
        if (signupOtp != null && signupOtp.trim().isNotEmpty)
          'signupOtp': signupOtp.trim(),
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

  Future<void> sendSignupOtp({
    String? email,
    String? phoneNumber,
    String? countryCode,
  }) async {
    await _api.post<void>(
      ApiEndpoints.authSendSignupOtp,
      data: {
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
        if (countryCode != null && countryCode.trim().isNotEmpty)
          'countryCode': countryCode.trim(),
      },
    );
  }

  Future<void> verifySignupOtp({
    String? email,
    String? phoneNumber,
    String? countryCode,
    required String otpCode,
  }) async {
    final trimmedEmail = email?.trim();
    final trimmedPhone = phoneNumber?.trim();
    final trimmedCountryCode = countryCode?.trim();
    final trimmedOtp = otpCode.trim();

    final identity = <String, dynamic>{
      if (trimmedEmail != null && trimmedEmail.isNotEmpty)
        'email': trimmedEmail
      else if (trimmedPhone != null && trimmedPhone.isNotEmpty)
        'phoneNumber': trimmedPhone,
      if ((trimmedEmail == null || trimmedEmail.isEmpty) &&
          trimmedPhone != null &&
          trimmedPhone.isNotEmpty &&
          trimmedCountryCode != null &&
          trimmedCountryCode.isNotEmpty)
        'countryCode': trimmedCountryCode,
    };

    await _api.post<void>(
      ApiEndpoints.authVerifySignupOtp,
      data: {
        ...identity,
        'signupOtp': trimmedOtp,
      },
    );
  }

  Future<void> forgotPassword({
    String? email,
    String? phoneNumber,
    String? countryCode,
  }) async {
    await _api.post<void>(
      ApiEndpoints.authForgotPassword,
      data: {
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
        if (countryCode != null && countryCode.trim().isNotEmpty)
          'countryCode': countryCode.trim(),
      },
    );
  }

  Future<void> resetPassword({
    String? userId,
    required String resetCode,
    required String newPassword,
    String? email,
    String? phoneNumber,
    String? countryCode,
  }) async {
    await _api.post<void>(
      ApiEndpoints.authResetPassword,
      data: {
        if (userId != null && userId.trim().isNotEmpty) 'userId': userId.trim(),
        'resetCode': resetCode.trim(),
        'newPassword': newPassword,
        // Sent as optional fallback for future backend compatibility.
        if (email != null && email.trim().isNotEmpty) 'email': email.trim(),
        if (phoneNumber != null && phoneNumber.trim().isNotEmpty)
          'phoneNumber': phoneNumber.trim(),
        if (countryCode != null && countryCode.trim().isNotEmpty)
          'countryCode': countryCode.trim(),
      },
    );
  }

  /// `PATCH /auth/me` — education fields after onboarding.
  Future<UserModel> patchEducationProfile({
    required String educationStatus,
    String? educationOtherDetail,
    String? schoolTrack,
    int? schoolGrade,
    int? universityYear,
  }) async {
    final payload = <String, dynamic>{
      'educationStatus': educationStatus,
      if (educationStatus == 'other' &&
          educationOtherDetail != null &&
          educationOtherDetail.trim().isNotEmpty)
        'educationOtherDetail': educationOtherDetail.trim(),
      if (educationStatus == 'school') ...{
        if (schoolTrack != null) 'schoolTrack': schoolTrack,
        if (schoolGrade != null) 'schoolGrade': schoolGrade,
      },
      if (educationStatus == 'university' && universityYear != null)
        'universityYear': universityYear,
    };

    try {
      await _api.patch<void>(ApiEndpoints.authMe, data: payload);
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) await TokenStorage.clearToken();
      rethrow;
    }
    return (await getCurrentUser()).user;
  }

  /// `PATCH /auth/me` — update the signed-in user's profile fields.
  /// [gender]: `female`, `male`, `other`. Omit a key to skip updating it.
  Future<UserModel> patchCurrentUserProfile({
    String? firstName,
    String? lastName,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? countryCode,
    String? gender,
  }) async {
    String? trimmed(String? s) {
      if (s == null) return null;
      final t = s.trim();
      return t.isEmpty ? null : t;
    }

    final payload = <String, dynamic>{
      if (trimmed(firstName) != null) 'firstName': trimmed(firstName),
      if (trimmed(lastName) != null) 'lastName': trimmed(lastName),
      if (trimmed(fullName) != null) 'fullName': trimmed(fullName),
      if (trimmed(email) != null) 'email': trimmed(email),
      if (trimmed(phoneNumber) != null) 'phoneNumber': trimmed(phoneNumber),
      if (trimmed(countryCode) != null) 'countryCode': trimmed(countryCode),
      if (trimmed(gender) != null) 'gender': trimmed(gender),
    };

    try {
      if (payload.isNotEmpty) {
        await _api.patch<void>(ApiEndpoints.authMe, data: payload);
      }
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) {
        await TokenStorage.clearToken();
      }
      rethrow;
    }
    return (await getCurrentUser()).user;
  }

  /// `POST /auth/me/avatar` (multipart) — upload profile photo.
  /// Returns the updated user with `profileImageUrl`.
  Future<UserModel> uploadAvatar(String filePath) async {
    try {
      await _api.postMultipart(
        ApiEndpoints.authMeAvatar,
        filePath: filePath,
        fileField: 'avatar',
      );
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) await TokenStorage.clearToken();
      rethrow;
    }
    return (await getCurrentUser()).user;
  }

  /// `DELETE /auth/me/avatar` — remove profile photo.
  Future<UserModel> deleteAvatar() async {
    try {
      await _api.delete<void>(ApiEndpoints.authMeAvatar);
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) await TokenStorage.clearToken();
      rethrow;
    }
    return (await getCurrentUser()).user;
  }

  Future<AuthMeData> getCurrentUser() async {
    try {
      final env = await _api.get<AuthMeData>(
        ApiEndpoints.authMe,
        dataFromJson: (raw) {
          final map = raw! as Map<String, dynamic>;
          final userJson = map['user'];
          if (userJson is! Map<String, dynamic>) {
            throw const FormatException('Missing user in /auth/me data');
          }
          final prefRaw = map['preference'];
          UserPreferencesModel? preference;
          if (prefRaw is Map) {
            preference = UserPreferencesModel.fromJson(
              Map<String, dynamic>.from(prefRaw),
            );
          }
          return AuthMeData(
            user: UserModel.fromJson(userJson),
            preference: preference,
          );
        },
      );
      final data = env.data;
      if (data == null) {
        throw ApiException(message: 'Empty user data', error: 'INVALID_RESPONSE');
      }
      return data;
    } on ApiException catch (e) {
      if (_isAuthFailure(e)) {
        await TokenStorage.clearToken();
      }
      rethrow;
    }
  }

  Future<void> logout() async {
    await _api.post<void>(ApiEndpoints.authLogout);
    await TokenStorage.clearToken();
  }

  bool _isAuthFailure(ApiException e) {
    final code = e.error;
    return e.statusCode == 401 ||
        code == 'AUTH_INVALID_TOKEN' ||
        code == 'AUTH_MISSING_TOKEN' ||
        code == 'USER_NOT_FOUND';
  }
}
