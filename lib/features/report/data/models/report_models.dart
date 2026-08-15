import 'package:flutter/material.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

enum ReportPeriod { daily, weekly, monthly, yearly }

class ReportBucket {
  const ReportBucket({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final double value;
  final Color? color;
}

class StudySubjectReportRow {
  const StudySubjectReportRow({
    this.studentSubjectId,
    required this.name,
    this.colorHex,
    this.studyMinutes = 0,
    this.sessionCount = 0,
    this.percentOfTotal = 0,
  });

  final String? studentSubjectId;
  final String name;
  final String? colorHex;
  final double studyMinutes;
  final int sessionCount;
  final int percentOfTotal;

  Color? get displayColor {
    final hex = colorHex?.replaceFirst('#', '');
    if (hex == null || hex.length != 6) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
}

class TaskReportBucket {
  const TaskReportBucket({
    required this.label,
    required this.completed,
    required this.total,
  });

  final String label;
  final int completed;
  final int total;

  double get ratio => total <= 0 ? 0 : completed / total;
}

class CommunityReportStats {
  const CommunityReportStats({
    this.messagesPosted = 0,
    this.materialShares = 0,
    this.channelJoins = 0,
    this.activityByDay = const [],
  });

  final int messagesPosted;
  final int materialShares;
  final int channelJoins;
  final List<ReportBucket> activityByDay;

  bool get hasActivity =>
      messagesPosted > 0 ||
      materialShares > 0 ||
      channelJoins > 0 ||
      activityByDay.any((b) => b.value > 0);
}

class AiToolRing {
  const AiToolRing({
    required this.key,
    required this.count,
    required this.percent,
    this.label,
  });

  final String key;
  final int count;
  final int percent;
  final String? label;
}

class AiToolReportStats {
  const AiToolReportStats({
    this.quizzes = 0,
    this.flashcards = 0,
    this.summaries = 0,
    this.mindMaps = 0,
    this.rings = const [],
  });

  final int quizzes;
  final int flashcards;
  final int summaries;
  final int mindMaps;
  final List<AiToolRing> rings;

  int percentForKey(String key, ReportPeriod period) {
    for (final ring in rings) {
      if (ring.key == key) {
        return ring.percent.clamp(0, 100);
      }
    }
    final count = switch (key) {
      'quizzes' => quizzes,
      'flashcards' => flashcards,
      'summaries' => summaries,
      'mindMaps' => mindMaps,
      _ => 0,
    };
    return _clientPercent(count, period);
  }

  int _clientPercent(int count, ReportPeriod period) {
    final target = switch (period) {
      ReportPeriod.daily => 1,
      ReportPeriod.weekly => 7,
      ReportPeriod.monthly => 28,
      ReportPeriod.yearly => 365,
    };
    return (count / target * 100).round().clamp(0, 100);
  }
}

class YourReportSnapshot {
  const YourReportSnapshot({
    required this.period,
    required this.periodLabel,
    required this.rangeStart,
    required this.rangeEnd,
    List<ReportBucket>? studyMinutes,
    AiToolReportStats? aiTools,
    List<DailyStreakDayModel>? streakWeek,
    int? currentStreak,
    int? longestStreak,
    int? freezesRemaining,
    List<ReportBucket>? tasksCompletedByDay,
    this.studyBySubject = const [],
    this.totalStudyMinutes,
    this.community = const CommunityReportStats(),
  })  : studyMinutes = studyMinutes ?? const [],
        aiTools = aiTools ?? const AiToolReportStats(),
        _streakWeek = streakWeek,
        _currentStreak = currentStreak,
        _longestStreak = longestStreak,
        _freezesRemaining = freezesRemaining,
        tasksCompletedByDay = tasksCompletedByDay ?? const [];

  final ReportPeriod period;
  final String periodLabel;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<ReportBucket> studyMinutes;
  final AiToolReportStats aiTools;
  final List<DailyStreakDayModel>? _streakWeek;
  final int? _currentStreak;
  final int? _longestStreak;
  final int? _freezesRemaining;
  final List<ReportBucket> tasksCompletedByDay;
  final List<StudySubjectReportRow> studyBySubject;
  final double? totalStudyMinutes;
  final CommunityReportStats community;

  /// Current ISO week streak days (Mon–Sun). Meaningful on weekly view.
  List<DailyStreakDayModel> get streakWeek => _streakWeek ?? const [];

  int get currentStreak => _currentStreak ?? 0;

  int get longestStreak => _longestStreak ?? 0;

  int get freezesRemaining => _freezesRemaining ?? 0;

  bool get hasStreakWeek => streakWeek.length == 7;

  bool get hasTasksCompletedData =>
      tasksCompletedByDay.any((bucket) => bucket.value > 0);

  bool get hasStudyBySubject =>
      studyBySubject.any((row) => row.studyMinutes > 0);

  bool get canExportPdf =>
      period == ReportPeriod.weekly ||
      period == ReportPeriod.monthly ||
      period == ReportPeriod.yearly;
}
