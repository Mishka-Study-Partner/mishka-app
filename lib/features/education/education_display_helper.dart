import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Human-readable education summary for profile display.
String formatEducationSummary(UserModel user, AppLocalizations l10n) {
  final status = user.educationStatus?.toLowerCase();
  if (status == null || status.isEmpty) {
    return l10n.profileFieldNotSet;
  }

  switch (status) {
    case 'school':
      final track = user.schoolTrack;
      final grade = user.schoolGrade;
      if (track == 'primary_school' && grade != null) {
        return switch (grade) {
          1 => l10n.firstPrimary,
          2 => l10n.secondPrimary,
          3 => l10n.thirdPrimary,
          4 => l10n.fourthPrimary,
          5 => l10n.fifthPrimary,
          6 => l10n.sixthPrimary,
          _ => l10n.school,
        };
      }
      if (track == 'middle_school' && grade != null) {
        return switch (grade) {
          1 => l10n.firstPreparatory,
          2 => l10n.secondPreparatory,
          3 => l10n.thirdPreparatory,
          _ => l10n.school,
        };
      }
      if (track == 'high_school' && grade != null) {
        return switch (grade) {
          1 => l10n.firstSecondary,
          2 => l10n.secondSecondary,
          3 => l10n.thirdSecondary,
          _ => l10n.school,
        };
      }
      return l10n.school;
    case 'university':
      final year = user.universityYear;
      if (year != null && year >= 1 && year <= 5) {
        return switch (year) {
          1 => l10n.firstYear,
          2 => l10n.secondYear,
          3 => l10n.thirdYear,
          4 => l10n.fourthYear,
          5 => l10n.fifthYear,
          _ => l10n.university,
        };
      }
      return l10n.university;
    case 'other':
      final detail = user.educationOtherDetail?.trim();
      if (detail != null && detail.isNotEmpty && detail != 'Not specified yet') {
        return detail;
      }
      return l10n.otherColon;
    default:
      return status;
  }
}
