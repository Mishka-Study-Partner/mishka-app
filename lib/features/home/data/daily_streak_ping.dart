import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/home/data/repositories/home_repository.dart';

/// Records app-open streak activity at most once per UTC calendar day.
class DailyStreakPing {
  DailyStreakPing({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;
  static bool _inFlight = false;

  static String utcDateString(DateTime utc) {
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> recordAppOpenIfNeeded() async {
    final todayUtc = utcDateString(DateTime.now().toUtc());
    if (AppPreferences.lastDailyStreakPingUtcDate == todayUtc || _inFlight) {
      return;
    }

    _inFlight = true;
    await AppPreferences.setLastDailyStreakPingUtcDate(todayUtc);
    try {
      await _repository.pingDailyStreak();
    } catch (_) {
      await AppPreferences.setLastDailyStreakPingUtcDate(null);
    } finally {
      _inFlight = false;
    }
  }
}
