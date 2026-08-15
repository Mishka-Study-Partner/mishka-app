import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/features/gamification/data/gamification_repository.dart';
import 'package:mishka_app/features/gamification/data/models/gamification_collect_result.dart';

/// Called from AI tool result screens when the user taps **Collect Badge**.
class GamificationBadgeCollector {
  GamificationBadgeCollector._();

  static final GamificationRepository _repository = GamificationRepository();

  static Future<GamificationCollectResult?> collect({
    required GamificationBadgeType type,
    required String sourceType,
    required String sourceId,
    Map<String, dynamic>? metadata,
  }) async {
    if (sourceId.isEmpty) return null;

    final badgeCode = type.apiCode;
    final idempotencyKey = _idempotencyKey(
      sourceType: sourceType,
      sourceId: sourceId,
      badgeCode: badgeCode,
    );

    return _repository.collectBadge(
      badgeCode: badgeCode,
      sourceType: sourceType,
      sourceId: sourceId,
      idempotencyKey: idempotencyKey,
      metadata: metadata,
    );
  }

  static Future<GamificationCollectResult?> collectQuizResult({
    required int correctCount,
    required int totalCount,
    required String sourceId,
    String? attemptId,
  }) async {
    if (sourceId.isEmpty && (attemptId == null || attemptId.isEmpty)) {
      return null;
    }

    final badgeCode = GamificationBadgeTypeX.quizBadgeCode(
      correctCount: correctCount,
      totalCount: totalCount,
    );
    final id = attemptId?.isNotEmpty == true ? attemptId! : sourceId;

    return _repository.collectBadge(
      badgeCode: badgeCode,
      sourceType: 'quiz',
      sourceId: id,
      idempotencyKey: 'quiz:$id:$badgeCode',
      metadata: {
        'correctCount': correctCount,
        'totalCount': totalCount,
      },
    );
  }

  static String _idempotencyKey({
    required String sourceType,
    required String sourceId,
    required String badgeCode,
  }) {
    return switch (sourceType) {
      'flashcards' => 'flashcards:$sourceId:complete',
      'summary' => 'summary:$sourceId:complete',
      'mindmap' => 'mindmap:$sourceId:complete',
      _ => '$sourceType:$sourceId:$badgeCode',
    };
  }
}
