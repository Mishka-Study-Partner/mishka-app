import 'package:flutter/material.dart';

import 'package:mishka_app/app/main_shell.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/education/education_flow_config.dart';

class EducationFlowService {
  EducationFlowService._();

  /// Saves education to the backend. Returns updated user on success.
  static Future<UserModel?> submitAndFinish({
    required BuildContext context,
    required EducationFlowConfig config,
    required String educationStatus,
    String? educationOtherDetail,
    String? schoolTrack,
    int? schoolGrade,
    int? universityYear,
  }) async {
    final user = await AuthRemoteDataSource(ApiService()).patchEducationProfile(
      educationStatus: educationStatus,
      educationOtherDetail: educationOtherDetail,
      schoolTrack: schoolTrack,
      schoolGrade: schoolGrade,
      universityYear: universityYear,
    );

    if (!context.mounted) return user;

    if (config.isProfileEdit) {
      Navigator.of(context).pop(user);
      return user;
    }

    await AppPreferences.setEducationSetupCompleted(true);
    if (!context.mounted) return user;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const MainScreen()),
      (_) => false,
    );
    return user;
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}
