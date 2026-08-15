import '../daily_streak_week_utils.dart';

class DailyStreakDayModel {
  const DailyStreakDayModel({
    required this.date,
    required this.state,
    this.status,
  });

  final String date;
  final String state;
  final String? status;

  bool get isCompleted =>
      state == 'past_done' ||
      state == 'today_done' ||
      status == 'completed' ||
      status == 'frozen';

  bool get isMissed => state == 'past_missed';

  bool get isFrozen => status == 'frozen' || state == 'frozen';

  bool get isToday =>
      state == 'today_done' || state == 'today_pending';

  bool get isTodayPending => state == 'today_pending';

  bool get isUpcoming => state == 'upcoming';

  Map<String, dynamic> toJson() => {
        'date': date,
        'state': state,
        if (status != null) 'status': status,
      };

  factory DailyStreakDayModel.fromJson(Map<String, dynamic> json) {
    final stateRaw = (json['state'] ?? '').toString();
    final state = stateRaw.isNotEmpty
        ? stateRaw
        : json['isCompleted'] == true
            ? 'past_done'
            : json['isToday'] == true
                ? 'today_pending'
                : json['isMissed'] == true
                    ? 'past_missed'
                    : 'upcoming';

    return DailyStreakDayModel(
      date: (json['date'] ?? '').toString(),
      state: state,
      status: json['status']?.toString(),
    );
  }
}

class DailyStreakModel {
  const DailyStreakModel({
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.freezesRemaining = 0,
    this.today,
    this.week = const [],
  });

  final int currentStreak;
  final int longestStreak;
  final int freezesRemaining;
  final String? today;
  final List<DailyStreakDayModel> week;

  /// Alias used by home UI.
  int get days => currentStreak;

  List<bool> get weekCompleted =>
      week.map((day) => day.isCompleted).toList(growable: false);

  Map<String, dynamic> toJson() => {
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'freezesRemaining': freezesRemaining,
        if (today != null) 'today': today,
        'week': week.map((day) => day.toJson()).toList(),
      };

  factory DailyStreakModel.fromJson(Object? raw) {
    if (raw is! Map) {
      return const DailyStreakModel();
    }
    final map = Map<String, dynamic>.from(raw);
    final current = _parseStreakCount(map);
    final longest = _parseInt(map['longestStreak'] ?? current);
    final freezes = _parseInt(map['freezesRemaining'] ?? 0);

    final weekRaw = _parseWeekRaw(map);
    final week = <DailyStreakDayModel>[];
    if (weekRaw is List) {
      final todayDate = map['today']?.toString();
      final anchorToday = parseStreakCalendarDate(todayDate ?? '') ??
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final weekStart = saturdayOfWeekContaining(anchorToday);

      for (var i = 0; i < weekRaw.length; i++) {
        final item = weekRaw[i];
        final slotDate = formatStreakCalendarDate(weekStart.add(Duration(days: i)));
        if (item is Map) {
          final day = DailyStreakDayModel.fromJson(
            Map<String, dynamic>.from(item),
          );
          week.add(
            day.date.isEmpty
                ? DailyStreakDayModel(date: slotDate, state: day.state, status: day.status)
                : day,
          );
        } else if (item == true || item == 1) {
          week.add(DailyStreakDayModel(date: slotDate, state: 'past_done'));
        } else {
          week.add(DailyStreakDayModel(date: slotDate, state: 'upcoming'));
        }
      }
    }

    return DailyStreakModel(
      currentStreak: current,
      longestStreak: longest,
      freezesRemaining: freezes,
      today: map['today']?.toString(),
      week: sanitizeStreakWeek(
        alignStreakWeek(
          week,
          today: map['today']?.toString(),
        ),
        currentStreak: current,
        longestStreak: longest,
        today: map['today']?.toString(),
      ),
    );
  }

  /// Reads the running streak total — never treats a `days` week array as a number.
  static int _parseStreakCount(Map<String, dynamic> map) {
    final current = map['currentStreak'];
    if (current != null) return _parseInt(current);

    final streakDays = map['streakDays'];
    if (streakDays != null) return _parseInt(streakDays);

    final days = map['days'];
    if (days is num || days is String) {
      return _parseInt(days);
    }
    return 0;
  }

  static List? _parseWeekRaw(Map<String, dynamic> map) {
    for (final key in ['week', 'weekCompleted', 'weekDays']) {
      final value = map[key];
      if (value is List) return value;
    }
    final days = map['days'];
    if (days is List) return days;
    return null;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
