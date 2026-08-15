import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

/// Parses `YYYY-MM-DD` (and ISO datetime prefixes) to a date-only value.
DateTime? parseStreakCalendarDate(String raw) {
  if (raw.isEmpty) return null;
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(raw.trim());
  if (match == null) return null;
  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

String formatStreakCalendarDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Saturday that starts the Sat–Fri week containing [day].
DateTime saturdayOfWeekContaining(DateTime day) {
  final normalized = DateTime(day.year, day.month, day.day);
  final daysSinceSaturday =
      (normalized.weekday - DateTime.saturday + 7) % 7;
  return normalized.subtract(Duration(days: daysSinceSaturday));
}

/// Places streak days on fixed Sat–Fri columns using each item's date.
List<DailyStreakDayModel> alignStreakWeek(
  List<DailyStreakDayModel> incoming, {
  String? today,
}) {
  if (incoming.length != 7) return incoming;

  final datedEntries = <MapEntry<DailyStreakDayModel, DateTime>>[];
  for (final day in incoming) {
    final parsed = parseStreakCalendarDate(day.date);
    if (parsed != null) {
      datedEntries.add(MapEntry(day, parsed));
    }
  }

  // Legacy boolean week (`weekCompleted`) has no dates — keep index order.
  if (datedEntries.isEmpty) return incoming;

  final anchorToday = _resolveAnchorToday(incoming, today);
  final weekStart = saturdayOfWeekContaining(anchorToday);
  final slots = List<DailyStreakDayModel?>.filled(7, null);

  for (final entry in datedEntries) {
    final index = entry.value.difference(weekStart).inDays;
    if (index >= 0 && index < 7) {
      slots[index] = entry.key;
    }
  }

  return List.generate(7, (index) {
    final existing = slots[index];
    if (existing != null) return existing;

    final slotDate = weekStart.add(Duration(days: index));
    final dateStr = formatStreakCalendarDate(slotDate);
    if (slotDate == anchorToday) {
      return DailyStreakDayModel(date: dateStr, state: 'today_pending');
    }
    return DailyStreakDayModel(date: dateStr, state: 'upcoming');
  });
}

/// Hides missed days before the user has started a streak; keeps real misses after.
List<DailyStreakDayModel> sanitizeStreakWeek(
  List<DailyStreakDayModel> week, {
  int currentStreak = 0,
  int longestStreak = 0,
  String? today,
}) {
  if (week.length != 7) return week;

  final hasEverStreaked = currentStreak > 0 || longestStreak > 0;
  final firstActivity = _firstStreakActivityDateInWeek(week);

  if (!hasEverStreaked && firstActivity == null) {
    return week
        .map(
          (day) => day.isMissed
              ? DailyStreakDayModel(
                  date: day.date,
                  state: 'upcoming',
                  status: day.status,
                )
              : day,
        )
        .toList();
  }

  final anchorToday = _resolveAnchorToday(week, today);
  final streakAnchor = firstActivity ??
      (hasEverStreaked ? saturdayOfWeekContaining(anchorToday) : null);
  if (streakAnchor == null) return week;

  return week.map((day) {
    if (!day.isMissed) return day;
    final parsed = parseStreakCalendarDate(day.date);
    if (parsed == null || parsed.isBefore(streakAnchor)) {
      return DailyStreakDayModel(
        date: day.date,
        state: 'upcoming',
        status: day.status,
      );
    }
    return day;
  }).toList();
}

DateTime? _firstStreakActivityDateInWeek(List<DailyStreakDayModel> week) {
  DateTime? earliest;
  for (final day in week) {
    if (!day.isCompleted && !day.isFrozen) continue;
    final parsed = parseStreakCalendarDate(day.date);
    if (parsed == null) continue;
    if (earliest == null || parsed.isBefore(earliest)) {
      earliest = parsed;
    }
  }
  return earliest;
}

DateTime _resolveAnchorToday(List<DailyStreakDayModel> incoming, String? today) {
  final fromField = parseStreakCalendarDate(today ?? '');
  if (fromField != null) return fromField;

  for (final day in incoming) {
    if (day.isToday) {
      final parsed = parseStreakCalendarDate(day.date);
      if (parsed != null) return parsed;
    }
  }

  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}
