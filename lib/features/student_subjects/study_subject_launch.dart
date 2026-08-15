import 'package:flutter/material.dart';
import 'package:mishka_app/features/student_subjects/presentation/widgets/study_subject_picker_sheet.dart';

/// Result of the study subject picker (`subjectId` null = no specific subject).
class StudySubjectPickerResult {
  const StudySubjectPickerResult({
    this.subjectId,
    this.subjectName,
  });

  final String? subjectId;
  final String? subjectName;
}

/// Shows optional subject picker, then runs [onStart] when user confirms.
abstract final class StudySubjectLaunch {
  static Future<void> pickSubjectAndStart(
    BuildContext context, {
    required Future<void> Function(String? studentSubjectId, String? subjectName)
        onStart,
  }) async {
    final result = await StudySubjectPickerSheet.show(context);
    if (!context.mounted || result == null) return;
    await onStart(result.subjectId, result.subjectName);
  }
}
