import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';

import '../models/user_preferences_me_model.dart';
import '../models/user_preferences_model.dart';

class UserPreferencesRemoteDataSource {
  UserPreferencesRemoteDataSource(this._api);

  final ApiService _api;

  /// `GET /users/{id}/preferences` — returns a single preference row in `data`.
  /// Missing row (`PREFERENCES_NOT_FOUND` / 404) yields `null` (use local prefs).
  Future<UserPreferencesModel?> fetchForUser(String userId) async {
    try {
      final env = await _api.get<UserPreferencesModel?>(
        ApiEndpoints.userPreferencesForUser(userId),
        dataFromJson: UserPreferencesModel.tryParseEnvelopeData,
      );
      return env.data;
    } on ApiException catch (e) {
      if (e.error == 'PREFERENCES_NOT_FOUND' || e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// `PUT /users/{id}/preferences` — upsert (`language`, `theme`, `notificationsEnabled`).
  Future<UserPreferencesModel> upsertForUser(
    String userId,
    UserPreferencesModel prefs,
  ) async {
    final env = await _api.put<UserPreferencesModel>(
      ApiEndpoints.userPreferencesForUser(userId),
      data: prefs.toUpsertJson(),
      dataFromJson: (raw) => UserPreferencesModel.fromJson(
        Map<String, dynamic>.from(raw! as Map),
      ),
    );
    final data = env.data;
    if (data == null) {
      throw ApiException(
        message: 'Empty preferences response',
        error: 'INVALID_RESPONSE',
      );
    }
    return data;
  }

  /// `GET /user-preferences/me` — includes report auto-email settings.
  Future<UserPreferencesMeModel?> fetchMe() async {
    try {
      final env = await _api.get<Map<String, dynamic>>(
        ApiEndpoints.userPreferencesMe,
        dataFromJson: (raw) {
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return <String, dynamic>{};
        },
      );
      final data = env.data;
      if (data == null) return null;
      return UserPreferencesMeModel.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// `PATCH /user-preferences/me` — partial update (report email, etc.).
  Future<UserPreferencesMeModel> patchMe(Map<String, dynamic> body) async {
    final env = await _api.patch<Map<String, dynamic>>(
      ApiEndpoints.userPreferencesMe,
      data: body,
      dataFromJson: (raw) {
        if (raw is Map) return Map<String, dynamic>.from(raw);
        throw const FormatException('Invalid preferences response');
      },
    );
    final data = env.data;
    if (data == null) {
      throw ApiException(
        message: 'Empty preferences response',
        error: 'INVALID_RESPONSE',
      );
    }
    return UserPreferencesMeModel.fromJson(data);
  }
}
