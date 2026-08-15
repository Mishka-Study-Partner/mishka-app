import 'package:intl/intl.dart';

class GamificationMonthlyUtils {
  GamificationMonthlyUtils._();

  static List<DateTime> monthTabs({required DateTime anchor}) {
    return List.generate(
      6,
      (i) => DateTime(anchor.year, anchor.month - 2 + i),
    );
  }

  static String formatWeekRange(
    DateTime start,
    DateTime end,
    String locale,
  ) {
    final df = DateFormat('d MMMM', locale);
    return '${df.format(start)} - ${df.format(end)}';
  }
}
