class GamificationMonthWeekStat {
  const GamificationMonthWeekStat({
    required this.weekIndex,
    required this.rangeStart,
    required this.rangeEnd,
    required this.goalMet,
    required this.progress,
    required this.progressLabel,
    this.detailSubtitle,
    this.badgesEarned,
  });

  final int weekIndex;
  final DateTime rangeStart;
  final DateTime rangeEnd;
  final bool goalMet;
  final double progress;
  final String progressLabel;
  final String? detailSubtitle;
  final int? badgesEarned;
}

enum GamificationStreakDayStatus { opened, missed, outsideMonth }

class GamificationStreakCalendarDay {
  const GamificationStreakCalendarDay({
    required this.date,
    required this.status,
  });

  final DateTime date;
  final GamificationStreakDayStatus status;
}

class GamificationMonthlyBadgeGroup {
  const GamificationMonthlyBadgeGroup({
    required this.title,
    required this.badgeAssetPath,
    required this.weeks,
    this.goalSubtitle,
  });

  final String title;
  final String badgeAssetPath;
  final List<GamificationMonthWeekStat> weeks;
  final String? goalSubtitle;
}
