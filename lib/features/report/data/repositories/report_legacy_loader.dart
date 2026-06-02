import 'package:intl/intl.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/report/data/data_sources/report_ai_activity_data_source.dart';
import 'package:mishka_app/features/report/data/data_sources/report_remote_data_source.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/todo_lists/data/data_sources/todo_remote_data_source.dart';
import 'package:mishka_app/features/todo_lists/data/models/task_api_model.dart';

/// Pre-bundle fallback: parallel legacy APIs still available on production today.
class ReportLegacyLoader {
  ReportLegacyLoader({
    ReportRemoteDataSource? remote,
    ReportAiActivityDataSource? aiActivity,
    TodoRemoteDataSource? tasks,
    HomeRemoteDataSource? home,
  })  : _remote = remote ?? ReportRemoteDataSource(ApiService()),
        _aiActivity = aiActivity ?? ReportAiActivityDataSource(ApiService()),
        _tasks = tasks ?? TodoRemoteDataSource(ApiService()),
        _home = home ?? HomeRemoteDataSource(ApiService());

  final ReportRemoteDataSource _remote;
  final ReportAiActivityDataSource _aiActivity;
  final TodoRemoteDataSource _tasks;
  final HomeRemoteDataSource _home;

  Future<YourReportSnapshot> loadReport(ReportPeriod period) async {
    final now = DateTime.now().toUtc();
    final range = _rangeForPeriod(period, now);
    final label = _periodLabel(period, range);

    final results = await Future.wait([
      _loadStudyBuckets(period, range),
      _aiActivity.countToolsInRange(
        rangeStart: range.start,
        rangeEnd: range.end,
      ),
      _home.getDailyStreak(),
      _tasks.getTasks(),
    ]);

    final studyMinutes = results[0] as List<ReportBucket>;
    final aiTools = results[1] as AiToolReportStats;
    final streak = results[2] as DailyStreakModel;
    final allTasks = results[3] as List<TaskApiModel>;

    return YourReportSnapshot(
      period: period,
      periodLabel: label,
      rangeStart: range.start,
      rangeEnd: range.end,
      studyMinutes: studyMinutes,
      aiTools: aiTools,
      streakWeek: _streakWeekForPeriod(period, streak),
      currentStreak: streak.currentStreak,
      longestStreak: streak.longestStreak,
      freezesRemaining: streak.freezesRemaining,
      tasksCompletedByDay: _tasksCompletedByDay(period, range, allTasks),
      dataSource: ReportDataSource.legacy,
    );
  }

  Future<List<ReportBucket>> _loadStudyBuckets(
    ReportPeriod period,
    _DateRange range,
  ) async {
    return switch (period) {
      ReportPeriod.daily => _dailyStudyBuckets(range.start),
      ReportPeriod.weekly => _weeklyStudyBuckets(range.start),
      ReportPeriod.monthly => _monthlyStudyBuckets(range.start),
      ReportPeriod.yearly => _yearlyStudyBuckets(range.start.year),
    };
  }

  Future<List<ReportBucket>> _dailyStudyBuckets(DateTime day) async {
    final report = await _remote.getDayReport(day);
    return _bucketSessionsByTimeSlots(report);
  }

  Future<List<ReportBucket>> _weeklyStudyBuckets(DateTime weekStart) async {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final report = await _remote.getWeekReport(weekStart);
    final minutesByWeekday = _minutesByWeekday(report.sessionSummaries);

    if (minutesByWeekday.isEmpty && report.sumStudySeconds > 0) {
      return [ReportBucket(label: 'Week', value: report.studyMinutes)];
    }

    return List.generate(
      7,
      (i) => ReportBucket(
        label: labels[i],
        value: minutesByWeekday[i + 1] ?? 0,
      ),
    );
  }

  Future<List<ReportBucket>> _monthlyStudyBuckets(DateTime monthStart) async {
    final month = monthStart.month;
    final year = monthStart.year;
    final report = await _remote.getMonthReport(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final weekCount = ((daysInMonth - 1) ~/ 7 + 1).clamp(1, 5);
    final buckets = List.filled(weekCount, 0.0);

    for (final session in report.sessionSummaries) {
      final started = _parseDate(session['startedAt'] ?? session['startUtc']);
      final seconds = _sessionStudySeconds(session);
      final minutes = seconds / 60.0;
      if (started != null) {
        final weekIndex = ((started.day - 1) ~/ 7).clamp(0, weekCount - 1);
        buckets[weekIndex] += minutes;
      } else if (minutes > 0 && buckets.isNotEmpty) {
        buckets[0] += minutes;
      }
    }

    if (report.sessionSummaries.isEmpty && report.sumStudySeconds > 0) {
      buckets[0] += report.studyMinutes;
    }

    return List.generate(
      weekCount,
      (i) => ReportBucket(label: 'W${i + 1}', value: buckets[i]),
    );
  }

  Future<List<ReportBucket>> _yearlyStudyBuckets(int year) async {
    const labels = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final reports = await Future.wait(
      List.generate(12, (i) => _remote.getMonthReport(year, i + 1)),
    );
    return List.generate(
      12,
      (i) => ReportBucket(label: labels[i], value: reports[i].studyMinutes),
    );
  }

  List<ReportBucket> _bucketSessionsByTimeSlots(StudyPeriodReport report) {
    final slots = <String, double>{
      '6-10': 0,
      '10-14': 0,
      '14-18': 0,
      '18-22': 0,
      '22-6': 0,
    };

    for (final session in report.sessionSummaries) {
      final started = _parseDate(
        session['startedAt'] ?? session['startUtc'] ?? session['createdAt'],
      );
      final minutes = _sessionStudySeconds(session) / 60.0;
      if (started == null) {
        slots['10-14'] = (slots['10-14'] ?? 0) + minutes;
        continue;
      }
      final hour = started.toUtc().hour;
      final key = switch (hour) {
        >= 6 && < 10 => '6-10',
        >= 10 && < 14 => '10-14',
        >= 14 && < 18 => '14-18',
        >= 18 && < 22 => '18-22',
        _ => '22-6',
      };
      slots[key] = (slots[key] ?? 0) + minutes;
    }

    if (report.sessionSummaries.isEmpty && report.sumStudySeconds > 0) {
      slots['10-14'] = report.studyMinutes;
    }

    return [
      ReportBucket(label: '6-10', value: slots['6-10'] ?? 0),
      ReportBucket(label: '10-14', value: slots['10-14'] ?? 0),
      ReportBucket(label: '14-18', value: slots['14-18'] ?? 0),
      ReportBucket(label: '18-22', value: slots['18-22'] ?? 0),
      ReportBucket(label: '22-6', value: slots['22-6'] ?? 0),
    ];
  }

  int _sessionStudySeconds(Map<String, dynamic> session) {
    return _parseInt(
      session['approximateMainStudySeconds'] ??
          session['studySeconds'] ??
          session['mainStudySeconds'],
    );
  }

  Map<int, double> _minutesByWeekday(List<Map<String, dynamic>> sessions) {
    final map = <int, double>{};
    for (final session in sessions) {
      final started = _parseDate(session['startedAt'] ?? session['startUtc']);
      if (started == null) continue;
      final weekday = started.toUtc().weekday;
      map[weekday] =
          (map[weekday] ?? 0) + _sessionStudySeconds(session) / 60.0;
    }
    return map;
  }

  List<DailyStreakDayModel> _streakWeekForPeriod(
    ReportPeriod period,
    DailyStreakModel streak,
  ) {
    if (period != ReportPeriod.weekly || streak.week.length < 7) {
      return const [];
    }
    return streak.week;
  }

  List<ReportBucket> _tasksCompletedByDay(
    ReportPeriod period,
    _DateRange range,
    List<TaskApiModel> tasks,
  ) {
    final labels = _taskDayBucketLabels(period, range);
    return labels.map((label) {
      final bucketRange = _taskDayBucketRange(period, range, label);
      final count = tasks.where((task) {
        if (task.resolvedStatus != TaskStatus.completed) return false;
        final completedOn = _taskCompletionDate(task);
        if (completedOn == null) return false;
        final utc = DateTime.utc(
          completedOn.year,
          completedOn.month,
          completedOn.day,
        );
        return !utc.isBefore(bucketRange.start) &&
            utc.isBefore(bucketRange.end);
      }).length;
      return ReportBucket(label: label, value: count.toDouble());
    }).toList();
  }

  DateTime? _taskCompletionDate(TaskApiModel task) {
    if (task.resolvedStatus != TaskStatus.completed) return null;
    return task.completedAt ?? task.updatedAt ?? task.deadline;
  }

  List<String> _taskDayBucketLabels(ReportPeriod period, _DateRange range) {
    return switch (period) {
      ReportPeriod.daily => const ['Today'],
      ReportPeriod.weekly => const [
          'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
        ],
      ReportPeriod.monthly => List.generate(
          DateTime(range.start.year, range.start.month + 1, 0).day,
          (i) => '${i + 1}',
        ),
      ReportPeriod.yearly => const [
          'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
          'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
        ],
    };
  }

  _DateRange _taskDayBucketRange(
    ReportPeriod period,
    _DateRange range,
    String label,
  ) {
    if (period == ReportPeriod.daily) return range;
    if (period == ReportPeriod.weekly) {
      const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final index = labels.indexOf(label);
      final start = _mondayUtc(range.start).add(Duration(days: index));
      return _DateRange(start, start.add(const Duration(days: 1)));
    }
    if (period == ReportPeriod.monthly) {
      final day = int.tryParse(label) ?? 1;
      final start = DateTime.utc(range.start.year, range.start.month, day);
      return _DateRange(start, start.add(const Duration(days: 1)));
    }
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final index = months.indexOf(label);
    final year = range.start.year;
    final start = DateTime.utc(year, index + 1, 1);
    final end = DateTime.utc(year, index + 2, 1);
    return _DateRange(start, end);
  }

  _DateRange _rangeForPeriod(ReportPeriod period, DateTime anchorUtc) {
    final today = DateTime.utc(anchorUtc.year, anchorUtc.month, anchorUtc.day);
    return switch (period) {
      ReportPeriod.daily =>
        _DateRange(today, today.add(const Duration(days: 1))),
      ReportPeriod.weekly => _DateRange(
          _mondayUtc(today),
          _mondayUtc(today).add(const Duration(days: 7)),
        ),
      ReportPeriod.monthly => _DateRange(
          DateTime.utc(today.year, today.month, 1),
          DateTime.utc(today.year, today.month + 1, 1),
        ),
      ReportPeriod.yearly => _DateRange(
          DateTime.utc(today.year, 1, 1),
          DateTime.utc(today.year + 1, 1, 1),
        ),
    };
  }

  String _periodLabel(ReportPeriod period, _DateRange range) {
    final fmt = DateFormat('MMM d, yyyy');
    return switch (period) {
      ReportPeriod.daily => fmt.format(range.start.toLocal()),
      ReportPeriod.weekly =>
        '${fmt.format(range.start.toLocal())} – ${fmt.format(range.end.subtract(const Duration(days: 1)).toLocal())}',
      ReportPeriod.monthly =>
        DateFormat('MMMM yyyy').format(range.start.toLocal()),
      ReportPeriod.yearly => range.start.year.toString(),
    };
  }

  DateTime _mondayUtc(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final delta = utc.weekday - DateTime.monday;
    return utc.subtract(Duration(days: delta < 0 ? 6 : delta));
  }

  DateTime? _parseDate(Object? raw) {
    if (raw == null) return null;
    return DateTime.tryParse(raw.toString());
  }

  int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _DateRange {
  const _DateRange(this.start, this.end);

  final DateTime start;
  final DateTime end;
}
