import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/gamification/data/gamification_badge_type.dart';
import 'package:mishka_app/features/gamification/data/gamification_dashboard_model.dart';
import 'package:mishka_app/features/gamification/data/gamification_monthly_model.dart';
import 'package:mishka_app/features/gamification/data/models/gamification_collect_result.dart';
import 'package:mishka_app/features/gamification/presentation/screens/gamification_monthly_screen.dart';
import 'package:mishka_app/features/gamification/utils/gamification_badge_assets.dart';

class GamificationRemoteDataSource {
  GamificationRemoteDataSource(this._api);

  final ApiService _api;

  static String monthQuery(DateTime month) {
    final y = month.year.toString().padLeft(4, '0');
    final m = month.month.toString().padLeft(2, '0');
    return '$y-$m';
  }

  Future<GamificationDashboardModel> getDashboard({String? weekStart}) async {
    final query = <String, dynamic>{'period': 'weekly'};
    if (weekStart != null && weekStart.isNotEmpty) {
      query['weekStart'] = weekStart;
    }

    final env = await _api.get<GamificationDashboardModel>(
      ApiEndpoints.gamificationDashboard,
      queryParameters: query,
      dataFromJson: (raw) {
        if (raw is! Map) return GamificationDashboardModel.empty();
        return GamificationDashboardModel.fromJson(
          Map<String, dynamic>.from(raw),
        );
      },
    );
    return env.data ?? GamificationDashboardModel.empty();
  }

  Future<GamificationCollectResult> collectBadge({
    required String badgeCode,
    required String sourceType,
    required String sourceId,
    required String idempotencyKey,
    Map<String, dynamic>? metadata,
  }) async {
    final env = await _api.post<GamificationCollectResult>(
      ApiEndpoints.gamificationBadgesCollect,
      data: {
        'badgeCode': badgeCode,
        'sourceType': sourceType,
        'sourceId': sourceId,
        'idempotencyKey': idempotencyKey,
        if (metadata != null && metadata.isNotEmpty) 'metadata': metadata,
      },
      dataFromJson: (raw) {
        if (raw is! Map) {
          return const GamificationCollectResult(
            success: false,
            created: false,
            badgeCode: '',
            timesEarnedThisWeek: 0,
            timesEarnedThisMonth: 0,
          );
        }
        return GamificationCollectResult.fromJson(
          Map<String, dynamic>.from(raw),
        );
      },
    );
    return env.data ??
        const GamificationCollectResult(
          success: false,
          created: false,
          badgeCode: '',
          timesEarnedThisWeek: 0,
          timesEarnedThisMonth: 0,
        );
  }

  Future<GamificationStreakMonthlyData> getStreakMonthly(DateTime month) async {
    final env = await _api.get<GamificationStreakMonthlyData>(
      ApiEndpoints.gamificationSectionMonthly('streak'),
      queryParameters: {'month': monthQuery(month)},
      dataFromJson: (raw) {
        if (raw is! Map) {
          return GamificationStreakMonthlyData.empty(month);
        }
        return GamificationStreakMonthlyData.fromJson(
          Map<String, dynamic>.from(raw),
          fallbackMonth: month,
        );
      },
    );
    return env.data ?? GamificationStreakMonthlyData.empty(month);
  }

  Future<GamificationProgressMonthlyData> getProgressMonthly({
    required GamificationMonthlySection section,
    required DateTime month,
  }) async {
    final apiSection = switch (section) {
      GamificationMonthlySection.todo => 'tasks',
      GamificationMonthlySection.study => 'study',
      GamificationMonthlySection.community => 'community',
      _ => throw ArgumentError('Not a progress section: $section'),
    };

    final env = await _api.get<GamificationProgressMonthlyData>(
      ApiEndpoints.gamificationSectionMonthly(apiSection),
      queryParameters: {'month': monthQuery(month)},
      dataFromJson: (raw) {
        if (raw is! Map) {
          return GamificationProgressMonthlyData.empty(month);
        }
        return GamificationProgressMonthlyData.fromJson(
          Map<String, dynamic>.from(raw),
          fallbackMonth: month,
        );
      },
    );
    return env.data ?? GamificationProgressMonthlyData.empty(month);
  }

  Future<GamificationAiToolsMonthlyData> getAiToolsMonthly(DateTime month) async {
    final env = await _api.get<GamificationAiToolsMonthlyData>(
      ApiEndpoints.gamificationSectionMonthly('ai-tools'),
      queryParameters: {'month': monthQuery(month)},
      dataFromJson: (raw) {
        if (raw is! Map) {
          return GamificationAiToolsMonthlyData.empty(month);
        }
        return GamificationAiToolsMonthlyData.fromJson(
          Map<String, dynamic>.from(raw),
          fallbackMonth: month,
        );
      },
    );
    return env.data ?? GamificationAiToolsMonthlyData.empty(month);
  }
}

class GamificationStreakMonthlyData {
  const GamificationStreakMonthlyData({
    required this.month,
    required this.streakDaysInMonth,
    required this.days,
  });

  final DateTime month;
  final int streakDaysInMonth;
  final List<GamificationStreakCalendarDay> days;

  factory GamificationStreakMonthlyData.empty(DateTime month) {
    return GamificationStreakMonthlyData(
      month: DateTime(month.year, month.month),
      streakDaysInMonth: 0,
      days: const [],
    );
  }

  factory GamificationStreakMonthlyData.fromJson(
    Map<String, dynamic> json, {
    required DateTime fallbackMonth,
  }) {
    final monthRaw = json['month']?.toString();
    final parsedMonth = DateTime.tryParse(monthRaw ?? '') ?? fallbackMonth;

    final daysRaw = json['days'] as List? ?? const [];
    final days = daysRaw
        .whereType<Map>()
        .map((item) {
          final map = Map<String, dynamic>.from(item);
          final dateRaw = map['date']?.toString() ?? '';
          final date = DateTime.tryParse(dateRaw) ??
              _parseDateOnly(dateRaw) ??
              fallbackMonth;
          final statusRaw = (map['status'] ?? '').toString();
          final status = switch (statusRaw) {
            'opened' => GamificationStreakDayStatus.opened,
            'missed' => GamificationStreakDayStatus.missed,
            _ => GamificationStreakDayStatus.outsideMonth,
          };
          return GamificationStreakCalendarDay(date: date, status: status);
        })
        .toList();

    return GamificationStreakMonthlyData(
      month: DateTime(parsedMonth.year, parsedMonth.month),
      streakDaysInMonth: _int(json['streakDaysInMonth']),
      days: days,
    );
  }

  static DateTime? _parseDateOnly(String raw) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw);
    if (match == null) return null;
    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class GamificationProgressMonthlyData {
  const GamificationProgressMonthlyData({
    required this.month,
    required this.goalSubtitle,
    required this.badgesEarnedInMonth,
    required this.weeks,
  });

  final DateTime month;
  final String goalSubtitle;
  final int badgesEarnedInMonth;
  final List<GamificationMonthWeekStat> weeks;

  factory GamificationProgressMonthlyData.empty(DateTime month) {
    return GamificationProgressMonthlyData(
      month: DateTime(month.year, month.month),
      goalSubtitle: '',
      badgesEarnedInMonth: 0,
      weeks: const [],
    );
  }

  factory GamificationProgressMonthlyData.fromJson(
    Map<String, dynamic> json, {
    required DateTime fallbackMonth,
  }) {
    final monthRaw = json['month']?.toString();
    final parsedMonth = DateTime.tryParse(monthRaw ?? '') ?? fallbackMonth;
    final weeksRaw = json['weeks'] as List? ?? const [];

    return GamificationProgressMonthlyData(
      month: DateTime(parsedMonth.year, parsedMonth.month),
      goalSubtitle: (json['goalSubtitle'] ?? '').toString(),
      badgesEarnedInMonth: _int(json['badgesEarnedInMonth']),
      weeks: weeksRaw
          .whereType<Map>()
          .map((w) => _weekFromJson(Map<String, dynamic>.from(w)))
          .toList(),
    );
  }

  static GamificationMonthWeekStat _weekFromJson(Map<String, dynamic> json) {
    final rangeStart = _parseDate(json['rangeStart']) ?? DateTime.now();
    final rangeEnd = _parseDate(json['rangeEnd']) ?? rangeStart;
    final progress = _double(json['progress']);
    final current = _double(json['current']);
    final goal = _double(json['goal']);
    final detailLine = (json['detailLine'] ?? '').toString();

    return GamificationMonthWeekStat(
      weekIndex: _int(json['weekIndex']),
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      goalMet: json['goalMet'] == true,
      progress: progress,
      progressLabel: detailLine.isNotEmpty
          ? detailLine
          : '${current.round()}/${goal.round()}',
      detailSubtitle: detailLine.isNotEmpty ? detailLine : null,
    );
  }

  static DateTime? _parseDate(dynamic raw) {
    if (raw == null) return null;
    final text = raw.toString();
    return DateTime.tryParse(text) ?? GamificationStreakMonthlyData._parseDateOnly(text);
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

class GamificationAiToolsMonthlyData {
  const GamificationAiToolsMonthlyData({
    required this.month,
    required this.groups,
  });

  final DateTime month;
  final List<GamificationMonthlyBadgeGroup> groups;

  factory GamificationAiToolsMonthlyData.empty(DateTime month) {
    return GamificationAiToolsMonthlyData(
      month: DateTime(month.year, month.month),
      groups: const [],
    );
  }

  factory GamificationAiToolsMonthlyData.fromJson(
    Map<String, dynamic> json, {
    required DateTime fallbackMonth,
  }) {
    final monthRaw = json['month']?.toString();
    final parsedMonth = DateTime.tryParse(monthRaw ?? '') ?? fallbackMonth;
    final groupsRaw = json['groups'] as List? ?? const [];

    return GamificationAiToolsMonthlyData(
      month: DateTime(parsedMonth.year, parsedMonth.month),
      groups: groupsRaw
          .whereType<Map>()
          .map((g) => _groupFromJson(Map<String, dynamic>.from(g)))
          .toList(),
    );
  }

  static GamificationMonthlyBadgeGroup _groupFromJson(
    Map<String, dynamic> json,
  ) {
    final badgeCode = (json['badgeCode'] ?? '').toString();
    final type = GamificationBadgeTypeX.fromApiCode(badgeCode);
    final weeksRaw = json['weeks'] as List? ?? const [];

    return GamificationMonthlyBadgeGroup(
      title: (json['title'] ?? '').toString(),
      badgeAssetPath: type != null
          ? GamificationBadgeAssets.assetFor(type)
          : GamificationBadgeAssets.assetFor(GamificationBadgeType.quizPerfect),
      weeks: weeksRaw
          .whereType<Map>()
          .map((w) => _aiWeekFromJson(Map<String, dynamic>.from(w)))
          .toList(),
      goalSubtitle: json['timesEarnedInMonth'] != null
          ? '${json['timesEarnedInMonth']}'
          : null,
    );
  }

  static GamificationMonthWeekStat _aiWeekFromJson(Map<String, dynamic> json) {
    final rangeStart =
        GamificationProgressMonthlyData._parseDate(json['rangeStart']) ??
            DateTime.now();
    final rangeEnd =
        GamificationProgressMonthlyData._parseDate(json['rangeEnd']) ??
            rangeStart;
    final badgesEarned = GamificationProgressMonthlyData._int(json['badgesEarned']);
    final detailSubtitle = (json['detailSubtitle'] ?? '').toString();
    final goalMet = badgesEarned > 0 || json['goalMet'] == true;

    return GamificationMonthWeekStat(
      weekIndex: GamificationProgressMonthlyData._int(json['weekIndex']),
      rangeStart: rangeStart,
      rangeEnd: rangeEnd,
      goalMet: goalMet,
      progress: goalMet ? 1 : 0.5,
      progressLabel: badgesEarned > 0 ? '$badgesEarned Badges' : '0 Badges',
      detailSubtitle: detailSubtitle.isNotEmpty ? detailSubtitle : null,
      badgesEarned: badgesEarned,
    );
  }
}
