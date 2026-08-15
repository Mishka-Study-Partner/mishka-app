import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';
import 'package:mishka_app/features/home/data/repositories/home_repository.dart';

/// Records app-open streak activity at most once per UTC calendar day.
class DailyStreakPing {
  DailyStreakPing({HomeRepository? repository})
      : _repository = repository ?? HomeRepository();

  final HomeRepository _repository;
  static bool _inFlight = false;
  static Future<DailyStreakModel?>? _lastPingFuture;

  static String utcDateString(DateTime utc) {
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  /// Waits until the current or most recent daily ping finishes (if any).
  static Future<void> whenPingSettled() async {
    await (_lastPingFuture ?? Future<DailyStreakModel?>.value(null));
  }

  /// Returns the ping response when a new ping runs; otherwise `null`.
  Future<DailyStreakModel?> recordAppOpenIfNeeded() async {
    final todayUtc = utcDateString(DateTime.now().toUtc());
    if (AppPreferences.lastDailyStreakPingUtcDate == todayUtc) {
      await whenPingSettled();
      return null;
    }
    if (_inFlight) {
      await whenPingSettled();
      return null;
    }

    _inFlight = true;
    final pingFuture = _runPing(todayUtc);
    _lastPingFuture = pingFuture;
    try {
      return await pingFuture;
    } finally {
      _inFlight = false;
    }
  }

  Future<DailyStreakModel?> _runPing(String todayUtc) async {
    await AppPreferences.setLastDailyStreakPingUtcDate(todayUtc);
    try {
      return await _repository.pingDailyStreak();
    } catch (_) {
      await AppPreferences.setLastDailyStreakPingUtcDate(null);
      return null;
    }
  }
}
