import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

enum ReportPeriod { daily, weekly, monthly, yearly }

enum ReportDataSource { bundle, legacy }

class ReportBucket {
  const ReportBucket({required this.label, required this.value});

  final String label;
  final double value;
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
  });

  final int messagesPosted;
  final int materialShares;
  final int channelJoins;

  bool get hasActivity =>
      messagesPosted > 0 || materialShares > 0 || channelJoins > 0;
}

class AiToolReportStats {
  const AiToolReportStats({
    this.quizzes = 0,
    this.flashcards = 0,
    this.summaries = 0,
    this.mindMaps = 0,
  });

  final int quizzes;
  final int flashcards;
  final int summaries;
  final int mindMaps;

  int percentFor(int count, ReportPeriod period) {
    final target = switch (period) {
      ReportPeriod.daily => 1,
      ReportPeriod.weekly => 7,
      ReportPeriod.monthly => 28,
      ReportPeriod.yearly => 365,
    };
    final goal = target.toDouble();
    return (count / goal * 100).round().clamp(0, 100);
  }
}

class StudyPeriodReport {
  const StudyPeriodReport({
    this.sumStudySeconds = 0,
    this.sessionSummaries = const [],
  });

  final int sumStudySeconds;
  final List<Map<String, dynamic>> sessionSummaries;

  double get studyMinutes => sumStudySeconds / 60.0;

  StudyPeriodReport merge(StudyPeriodReport other) {
    return StudyPeriodReport(
      sumStudySeconds: sumStudySeconds + other.sumStudySeconds,
      sessionSummaries: [...sessionSummaries, ...other.sessionSummaries],
    );
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
    this.community = const CommunityReportStats(),
    this.dataSource = ReportDataSource.bundle,
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
  final CommunityReportStats community;
  final ReportDataSource dataSource;

  /// Current ISO week streak days (Mon–Sun). Meaningful on weekly view.
  List<DailyStreakDayModel> get streakWeek => _streakWeek ?? const [];

  int get currentStreak => _currentStreak ?? 0;

  int get longestStreak => _longestStreak ?? 0;

  int get freezesRemaining => _freezesRemaining ?? 0;

  bool get hasStreakWeek => streakWeek.length == 7;

  bool get hasTasksCompletedData =>
      tasksCompletedByDay.any((bucket) => bucket.value > 0);

  bool get canExportPdf =>
      period == ReportPeriod.weekly ||
      period == ReportPeriod.monthly ||
      period == ReportPeriod.yearly;
}
