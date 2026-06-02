import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';

class ReportExportResult {
  const ReportExportResult({
    required this.reportId,
    required this.periodLabel,
    this.pdfUrl,
    this.expiresAt,
    this.emailedTo,
    this.emailSentAt,
    this.delivery,
  });

  final String reportId;
  final String periodLabel;
  final String? pdfUrl;
  final DateTime? expiresAt;
  final String? emailedTo;
  final DateTime? emailSentAt;
  final String? delivery;

  factory ReportExportResult.fromJson(Map<String, dynamic> json) {
    return ReportExportResult(
      reportId: (json['reportId'] ?? '').toString(),
      periodLabel: (json['periodLabel'] ?? '').toString(),
      pdfUrl: json['pdfUrl']?.toString(),
      expiresAt: _parseDate(json['expiresAt']),
      emailedTo: json['emailedTo']?.toString(),
      emailSentAt: _parseDate(json['emailSentAt']),
      delivery: json['delivery']?.toString(),
    );
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }
}

class YourReportBundleModel {
  const YourReportBundleModel({
    required this.period,
    required this.periodLabel,
    required this.rangeStart,
    required this.rangeEnd,
    this.studyMinutes = const [],
    this.aiTools = const AiToolReportStats(),
    this.streakWeek = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezesRemaining = 0,
    this.tasksCompletedByDay = const [],
    this.community = const CommunityReportStats(),
  });

  final ReportPeriod period;
  final String periodLabel;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final List<ReportBucket> studyMinutes;
  final AiToolReportStats aiTools;
  final List<DailyStreakDayModel> streakWeek;
  final int currentStreak;
  final int longestStreak;
  final int freezesRemaining;
  final List<ReportBucket> tasksCompletedByDay;
  final CommunityReportStats community;

  YourReportSnapshot toSnapshot() {
    return YourReportSnapshot(
      period: period,
      periodLabel: periodLabel,
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      studyMinutes: studyMinutes,
      aiTools: aiTools,
      streakWeek: streakWeek,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      freezesRemaining: freezesRemaining,
      tasksCompletedByDay: tasksCompletedByDay,
      community: community,
      dataSource: ReportDataSource.bundle,
    );
  }

  factory YourReportBundleModel.fromJson(Map<String, dynamic> json) {
    final period = _periodFromString(json['period']?.toString());
    final studyRaw = json['study'];
    final aiRaw = json['aiTools'];
    final streakRaw = json['streak'];
    final tasksRaw = json['tasksCompleted'];
    final communityRaw = json['community'];

    return YourReportBundleModel(
      period: period,
      periodLabel: (json['periodLabel'] ?? '').toString(),
      rangeStart: _parseDate(json['rangeStart']) ?? DateTime.now().toUtc(),
      rangeEnd: _parseDate(json['rangeEnd']) ?? DateTime.now().toUtc(),
      studyMinutes: _parseStudyBuckets(studyRaw),
      aiTools: _parseAiTools(aiRaw),
      streakWeek: _parseStreakWeek(streakRaw),
      currentStreak: _parseInt(
        streakRaw is Map ? streakRaw['currentStreak'] : null,
      ),
      longestStreak: _parseInt(
        streakRaw is Map ? streakRaw['longestStreak'] : null,
      ),
      freezesRemaining: _parseInt(
        streakRaw is Map ? streakRaw['freezesRemaining'] : null,
      ),
      tasksCompletedByDay: _parseTaskBuckets(tasksRaw),
      community: _parseCommunity(communityRaw),
    );
  }

  static CommunityReportStats _parseCommunity(Object? raw) {
    if (raw is! Map) return const CommunityReportStats();
    final totals = raw['totals'];
    if (totals is! Map) return const CommunityReportStats();
    final map = Map<String, dynamic>.from(totals);
    return CommunityReportStats(
      messagesPosted: _parseInt(map['messagesPosted']),
      materialShares: _parseInt(map['materialShares']),
      channelJoins: _parseInt(map['channelJoins']),
    );
  }

  static ReportPeriod _periodFromString(String? raw) {
    return switch (raw?.toLowerCase()) {
      'daily' => ReportPeriod.daily,
      'monthly' => ReportPeriod.monthly,
      'yearly' => ReportPeriod.yearly,
      _ => ReportPeriod.weekly,
    };
  }

  static List<ReportBucket> _parseStudyBuckets(Object? raw) {
    if (raw is! Map) return const [];
    final buckets = raw['buckets'];
    if (buckets is! List) return const [];
    return buckets.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final label = (map['label'] ?? '').toString();
      final minutes = _parseDouble(
        map['studyMinutes'] ?? map['value'] ?? map['minutes'],
      );
      return ReportBucket(label: label, value: minutes);
    }).toList();
  }

  static AiToolReportStats _parseAiTools(Object? raw) {
    if (raw is! Map) return const AiToolReportStats();
    final map = Map<String, dynamic>.from(raw);
    return AiToolReportStats(
      quizzes: _parseInt(map['quizzes']),
      flashcards: _parseInt(map['flashcards']),
      summaries: _parseInt(map['summaries']),
      mindMaps: _parseInt(map['mindMaps']),
    );
  }

  static List<DailyStreakDayModel> _parseStreakWeek(Object? raw) {
    if (raw is! Map) return const [];
    final week = raw['week'];
    if (week is! List) return const [];
    return week.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      if (map.containsKey('state')) {
        return DailyStreakDayModel.fromJson(map);
      }
      final state = map['isCompleted'] == true
          ? 'past_done'
          : map['isToday'] == true
              ? 'today_pending'
              : map['isMissed'] == true
                  ? 'past_missed'
                  : 'upcoming';
      return DailyStreakDayModel(
        date: (map['date'] ?? '').toString(),
        state: state,
        status: map['status']?.toString(),
      );
    }).toList();
  }

  static List<ReportBucket> _parseTaskBuckets(Object? raw) {
    if (raw is! Map) return const [];
    final buckets = raw['buckets'];
    if (buckets is! List) return const [];
    return buckets.whereType<Map>().map((item) {
      final map = Map<String, dynamic>.from(item);
      final label = _taskBucketLabel(map);
      final count = _parseDouble(
        map['completedCount'] ?? map['value'] ?? map['count'],
      );
      return ReportBucket(label: label, value: count);
    }).toList();
  }

  static String _taskBucketLabel(Map<String, dynamic> map) {
    final label = (map['label'] ?? '').toString();
    if (label.isEmpty) return label;
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(label)) {
      try {
        final date = DateTime.parse(label);
        const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return weekdays[date.weekday - 1];
      } catch (_) {
        return label;
      }
    }
    return label;
  }

  static DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  static int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(Object? value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
