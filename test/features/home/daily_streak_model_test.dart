import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

void main() {
  group('DailyStreakModel.fromJson', () {
    test('uses days array as week rows, not streak count', () {
      final model = DailyStreakModel.fromJson({
        'longestStreak': 12,
        'freezesRemaining': 1,
        'today': '2026-05-24',
        'days': [
          {'date': '2026-05-24', 'state': 'today_pending'},
          {'date': '2026-05-25', 'state': 'upcoming'},
          {'date': '2026-05-26', 'state': 'upcoming'},
          {'date': '2026-05-27', 'state': 'upcoming'},
          {'date': '2026-05-28', 'state': 'upcoming'},
          {'date': '2026-05-29', 'state': 'upcoming'},
          {'date': '2026-05-30', 'state': 'upcoming'},
        ],
      });

      expect(model.currentStreak, 0);
      expect(model.longestStreak, 12);
      expect(model.week, hasLength(7));
      expect(model.week.any((d) => d.isToday), isTrue);
    });

    test('prefers currentStreak over days array', () {
      final model = DailyStreakModel.fromJson({
        'currentStreak': 9,
        'longestStreak': 12,
        'days': [
          {'date': '2026-05-24', 'state': 'today_pending'},
          {'date': '2026-05-25', 'state': 'upcoming'},
          {'date': '2026-05-26', 'state': 'upcoming'},
          {'date': '2026-05-27', 'state': 'upcoming'},
          {'date': '2026-05-28', 'state': 'upcoming'},
          {'date': '2026-05-29', 'state': 'upcoming'},
          {'date': '2026-05-30', 'state': 'upcoming'},
        ],
      });

      expect(model.currentStreak, 9);
    });

    test('falls back to streakDays when currentStreak is absent', () {
      final model = DailyStreakModel.fromJson({
        'streakDays': 4,
        'longestStreak': 10,
        'week': List.filled(7, {'state': 'upcoming'}),
      });

      expect(model.currentStreak, 4);
    });
  });
}
