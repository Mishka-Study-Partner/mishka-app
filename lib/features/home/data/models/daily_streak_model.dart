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

  factory DailyStreakDayModel.fromJson(Map<String, dynamic> json) {
    return DailyStreakDayModel(
      date: (json['date'] ?? '').toString(),
      state: (json['state'] ?? '').toString(),
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

  factory DailyStreakModel.fromJson(Object? raw) {
    if (raw is! Map) {
      return const DailyStreakModel();
    }
    final map = Map<String, dynamic>.from(raw);
    final current = _parseInt(
      map['currentStreak'] ?? map['streakDays'] ?? map['days'] ?? 0,
    );
    final longest = _parseInt(map['longestStreak'] ?? current);
    final freezes = _parseInt(map['freezesRemaining'] ?? 0);

    final weekRaw = map['week'] ?? map['weekCompleted'] ?? map['weekDays'];
    final week = <DailyStreakDayModel>[];
    if (weekRaw is List) {
      for (final item in weekRaw) {
        if (item is Map) {
          week.add(DailyStreakDayModel.fromJson(Map<String, dynamic>.from(item)));
        } else if (item == true || item == 1) {
          week.add(const DailyStreakDayModel(date: '', state: 'past_done'));
        } else {
          week.add(const DailyStreakDayModel(date: '', state: 'upcoming'));
        }
      }
    }

    return DailyStreakModel(
      currentStreak: current,
      longestStreak: longest,
      freezesRemaining: freezes,
      today: map['today']?.toString(),
      week: week,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
