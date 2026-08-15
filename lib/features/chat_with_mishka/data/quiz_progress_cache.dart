import 'dart:convert';

import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/chat_with_mishka/data/quiz_progress_metadata.dart';

/// Device-local fallback when chat message PATCH is unavailable on the backend.
class QuizProgressCache {
  QuizProgressCache._();

  static String _key(String messageId) => 'mishka_quiz_progress_$messageId';

  static Map<String, dynamic> mergeStoredProgress(
    Map<String, dynamic> toolData,
    String? messageId,
  ) {
    if (messageId == null || messageId.isEmpty) return toolData;
    if (readQuizProgress(toolData) != null) return toolData;

    final stored = read(messageId);
    if (stored == null) return toolData;

    return applyQuizProgress(toolData: toolData, progress: stored);
  }

  static QuizProgressSnapshot? read(String messageId) {
    final raw = AppPreferences.sharedPreferences?.getString(_key(messageId));
    if (raw == null || raw.isEmpty) return null;
    try {
      return QuizProgressSnapshot.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(
    String messageId,
    QuizProgressSnapshot progress,
  ) async {
    await AppPreferences.sharedPreferences?.setString(
      _key(messageId),
      jsonEncode(progress.toJson()),
    );
  }

  static Future<void> clear(String messageId) async {
    await AppPreferences.sharedPreferences?.remove(_key(messageId));
  }
}
