/// Earned badge categories shown on the Gamification hub and result screens.
enum GamificationBadgeType {
  quizPerfect,
  quizScore80,
  quizKeepLearning,
  flashcardsComplete,
  summaryComplete,
  mindMapComplete,
  chatPoints,
}

extension GamificationBadgeTypeX on GamificationBadgeType {
  String get storageKey => name;

  /// Backend `badge_definitions.code` / dashboard `aiToolBadges[].code`.
  String get apiCode => switch (this) {
        GamificationBadgeType.quizPerfect => 'quiz_perfect',
        GamificationBadgeType.quizScore80 => 'quiz_score_80',
        GamificationBadgeType.quizKeepLearning => 'quiz_keep_learning',
        GamificationBadgeType.flashcardsComplete => 'flashcards_complete',
        GamificationBadgeType.summaryComplete => 'summary_complete',
        GamificationBadgeType.mindMapComplete => 'mindmap_complete',
        GamificationBadgeType.chatPoints => 'chat_points',
      };

  static GamificationBadgeType? fromApiCode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final type in GamificationBadgeType.values) {
      if (type.apiCode == raw) return type;
    }
    return null;
  }

  static String quizBadgeCode({
    required int correctCount,
    required int totalCount,
  }) {
    return quizFromScore(
      correctCount: correctCount,
      totalCount: totalCount,
    ).apiCode;
  }

  static GamificationBadgeType? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    for (final type in GamificationBadgeType.values) {
      if (type.name == raw) return type;
    }
    return null;
  }

  /// Maps quiz score to one of the three quiz badge tiers.
  static GamificationBadgeType quizFromScore({
    required int correctCount,
    required int totalCount,
  }) {
    if (totalCount <= 0) return GamificationBadgeType.quizKeepLearning;
    if (correctCount >= totalCount) return GamificationBadgeType.quizPerfect;
    if (correctCount * 10 >= totalCount * 8) {
      return GamificationBadgeType.quizScore80;
    }
    return GamificationBadgeType.quizKeepLearning;
  }
}
