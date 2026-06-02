import 'package:mishka_app/features/settings/data/models/user_preferences_model.dart';

import 'user_model.dart';

/// `GET /auth/me` — user profile plus optional embedded preference row.
class AuthMeData {
  const AuthMeData({
    required this.user,
    this.preference,
  });

  final UserModel user;
  final UserPreferencesModel? preference;
}
