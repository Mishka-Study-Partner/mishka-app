import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

class GamificationAiToolBadgeStat {
  const GamificationAiToolBadgeStat({
    required this.type,
    required this.timesEarned,
    this.chatPointsThisWeek = 0,
  });

  final GamificationBadgeType type;
  /// Weekly count from `timesEarnedThisWeek` on the dashboard API.
  final int timesEarned;
  final int chatPointsThisWeek;
}

class GamificationProgressSection {
  const GamificationProgressSection({
    required this.currentValue,
    required this.goalValue,
    required this.badgesEarnedThisMonth,
    required this.unitLabel,
    this.progress,
  });

  final double currentValue;
  final double goalValue;
  final int badgesEarnedThisMonth;
  final String unitLabel;
  final double? progress;

  double get computedProgress =>
      progress ??
      (goalValue <= 0 ? 0 : (currentValue / goalValue).clamp(0.0, 1.0));

  double get remaining => (goalValue - currentValue).clamp(0, goalValue);
}

class GamificationDashboardModel {
  const GamificationDashboardModel({
    required this.streakDays,
    required this.streakWeek,
    required this.freezesRemaining,
    required this.tasks,
    required this.aiToolBadges,
    required this.study,
    required this.community,
    this.chatPointsThisWeek = 0,
  });

  final int streakDays;
  final List<DailyStreakDayModel> streakWeek;
  final int freezesRemaining;
  final GamificationProgressSection tasks;
  final List<GamificationAiToolBadgeStat> aiToolBadges;
  final GamificationProgressSection study;
  final GamificationProgressSection community;
  final int chatPointsThisWeek;

  factory GamificationDashboardModel.empty() {
    return GamificationDashboardModel(
      streakDays: 0,
      streakWeek: const [],
      freezesRemaining: 0,
      tasks: const GamificationProgressSection(
        currentValue: 0,
        goalValue: 30,
        badgesEarnedThisMonth: 0,
        unitLabel: 'tasks',
      ),
      aiToolBadges: [
        for (final type in GamificationBadgeType.values)
          GamificationAiToolBadgeStat(type: type, timesEarned: 0),
      ],
      study: const GamificationProgressSection(
        currentValue: 0,
        goalValue: 21,
        badgesEarnedThisMonth: 0,
        unitLabel: 'hrs',
      ),
      community: const GamificationProgressSection(
        currentValue: 0,
        goalValue: 700,
        badgesEarnedThisMonth: 0,
        unitLabel: '%',
      ),
      chatPointsThisWeek: 0,
    );
  }

  factory GamificationDashboardModel.fromJson(Map<String, dynamic> json) {
    final streakRaw = json['streak'];
    final streak = streakRaw is Map
        ? DailyStreakModel.fromJson(streakRaw)
        : const DailyStreakModel();

    return GamificationDashboardModel(
      streakDays: streak.currentStreak,
      streakWeek: streak.week,
      freezesRemaining: streak.freezesRemaining,
      tasks: _progressSection(
        json['tasks'],
        defaultGoal: 30,
        unitLabel: 'tasks',
        valueKeys: ('current', 'goal'),
      ),
      study: _progressSection(
        json['study'],
        defaultGoal: 21,
        unitLabel: 'hrs',
        valueKeys: ('currentHours', 'goalHours'),
        fallbackKeys: ('currentMinutes', 'goalMinutes'),
        scale: 1 / 60,
      ),
      community: _progressSection(
        json['community'],
        defaultGoal: 700,
        unitLabel: '%',
        valueKeys: ('currentScore', 'goalScore'),
      ),
      aiToolBadges: _parseAiBadges(json['aiToolBadges']),
      chatPointsThisWeek: _chatPointsThisWeek(json['aiToolBadges']),
    );
  }

  static GamificationProgressSection _progressSection(
    dynamic raw, {
    required double defaultGoal,
    required String unitLabel,
    required (String, String) valueKeys,
    (String, String)? fallbackKeys,
    double scale = 1,
  }) {
    if (raw is! Map) {
      return GamificationProgressSection(
        currentValue: 0,
        goalValue: defaultGoal,
        badgesEarnedThisMonth: 0,
        unitLabel: unitLabel,
      );
    }
    final map = Map<String, dynamic>.from(raw);
    var current = _double(map[valueKeys.$1]);
    var goal = _double(map[valueKeys.$2]);
    if (current == 0 && goal == 0 && fallbackKeys != null) {
      current = _double(map[fallbackKeys.$1]) * scale;
      goal = _double(map[fallbackKeys.$2]) * scale;
      if (goal == 0) goal = defaultGoal;
    }
    if (goal == 0) goal = defaultGoal;

    return GamificationProgressSection(
      currentValue: current,
      goalValue: goal,
      badgesEarnedThisMonth: _int(map['badgesEarnedThisMonth']),
      unitLabel: unitLabel,
      progress: map['progress'] != null ? _double(map['progress']) : null,
    );
  }

  static List<GamificationAiToolBadgeStat> _parseAiBadges(dynamic raw) {
    if (raw is! List) return const [];

    final byType = <GamificationBadgeType, GamificationAiToolBadgeStat>{};
    for (final item in raw.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      final code = (map['code'] ?? '').toString();
      final type = GamificationBadgeTypeX.fromApiCode(code);
      if (type == null) continue;
      byType[type] = GamificationAiToolBadgeStat(
        type: type,
        timesEarned: _int(map['timesEarnedThisWeek'] ?? map['timesEarned']),
        chatPointsThisWeek: _int(map['chatPointsThisWeek']),
      );
    }

    return [
      for (final type in GamificationBadgeType.values)
        byType[type] ??
            GamificationAiToolBadgeStat(type: type, timesEarned: 0),
    ];
  }

  static int _chatPointsThisWeek(dynamic raw) {
    if (raw is! List) return 0;
    for (final item in raw.whereType<Map>()) {
      final map = Map<String, dynamic>.from(item);
      if (map['code']?.toString() == 'chat_points') {
        return _int(map['chatPointsThisWeek']);
      }
    }
    return 0;
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _double(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}
