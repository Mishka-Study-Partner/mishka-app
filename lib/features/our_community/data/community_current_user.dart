import 'dart:convert';

import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';

/// Cached signed-in user, if available.
UserModel? readCachedUser() {
  final raw = AppPreferences.cachedUserJson;
  if (raw == null || raw.isEmpty) return null;
  try {
    return UserModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  } catch (_) {
    return null;
  }
}

/// Cached signed-in user id, if available.
String? readCachedCurrentUserId() {
  final raw = AppPreferences.cachedUserJson;
  if (raw == null || raw.isEmpty) return null;
  try {
    final user = UserModel.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
    return user.id.isEmpty ? null : user.id;
  } catch (_) {
    return null;
  }
}
