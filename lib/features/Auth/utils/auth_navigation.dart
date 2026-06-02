import 'package:flutter/material.dart';

import 'package:mishka_app/app/main_shell.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/education/presentation/screens/education_status_screen.dart';

/// Post-auth navigation (sign-up, login) — avoids popping back to intro/welcome.
class AuthNavigation {
  AuthNavigation._();

  static bool _hasEducationProfile(UserModel user) {
    final status = user.educationStatus?.trim();
    return status != null && status.isNotEmpty;
  }

  static Future<void> goAfterAuthentication(
    BuildContext context,
    UserModel user,
  ) async {
    // User reached auth screens only after intro/welcome.
    await AppPreferences.setOnboardingIntroCompleted(true);

    final hasEducation = _hasEducationProfile(user);
    await AppPreferences.setEducationSetupCompleted(hasEducation);

    if (!context.mounted) return;

    final destination = hasEducation
        ? const MainScreen()
        : const EducationStatusScreen();

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => destination),
      (_) => false,
    );
  }
}
