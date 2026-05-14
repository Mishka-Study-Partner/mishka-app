class DailyStreakModel {
  const DailyStreakModel({
    required this.days,
    this.weekCompleted = const [],
  });

  final int days;

  /// Boolean list (Mon–Sun) indicating which days of the current week are completed.
  /// If the API doesn't provide this, the home screen infers it from [days].
  final List<bool> weekCompleted;

  factory DailyStreakModel.fromJson(Object? raw) {
    if (raw is Map<String, dynamic>) {
      final value = raw['streakDays'] ?? raw['days'] ?? raw['currentStreak'] ?? 0;
      final days = (value as num?)?.toInt() ?? 0;

      List<bool> week = const [];
      final weekRaw = raw['weekCompleted'] ?? raw['weekDays'] ?? raw['week'];
      if (weekRaw is List) {
        week = weekRaw.map((e) {
          if (e == true || e == 1) return true;
          if (e is Map) {
            final state = (e['state'] ?? '').toString();
            final status = (e['status'] ?? '').toString();
            return state == 'completed' ||
                status == 'completed' ||
                status == 'done';
          }
          return false;
        }).toList();
      }

      return DailyStreakModel(days: days, weekCompleted: week);
    }
    return const DailyStreakModel(days: 0);
  }
}
