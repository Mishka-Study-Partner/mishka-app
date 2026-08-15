import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/features/home/data/daily_streak_week_utils.dart';
import 'package:mishka_app/features/home/data/models/daily_streak_model.dart';

void main() {
  group('alignStreakWeek', () {
    test('keeps Sat–Fri order when API already aligned', () {
      final week = [
        DailyStreakDayModel(date: '2026-05-16', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-17', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-18', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-19', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-20', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-21', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-22', state: 'today_pending'),
      ];

      final aligned = alignStreakWeek(week, today: '2026-05-22');

      expect(aligned[0].date, '2026-05-16');
      expect(aligned[0].isCompleted, isTrue);
      expect(aligned[1].isMissed, isTrue);
      expect(aligned[6].isToday, isTrue);
    });

    test('maps done days to correct weekday when API order is shifted', () {
      final week = [
        DailyStreakDayModel(date: '2026-05-20', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-22', state: 'today_pending'),
        DailyStreakDayModel(date: '2026-05-21', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-18', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-17', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-19', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-16', state: 'past_done'),
      ];

      final aligned = alignStreakWeek(week, today: '2026-05-22');

      expect(aligned[0].date, '2026-05-16');
      expect(aligned[0].isCompleted, isTrue);
      expect(aligned[1].isMissed, isTrue);
      expect(aligned[2].isCompleted, isTrue);
      expect(aligned[3].isCompleted, isTrue);
      expect(aligned[4].isCompleted, isTrue);
      expect(aligned[5].isCompleted, isTrue);
      expect(aligned[6].isToday, isTrue);
    });

    test('preserves legacy boolean week without dates', () {
      const week = [
        DailyStreakDayModel(date: '', state: 'past_done'),
        DailyStreakDayModel(date: '', state: 'past_done'),
        DailyStreakDayModel(date: '', state: 'upcoming'),
        DailyStreakDayModel(date: '', state: 'upcoming'),
        DailyStreakDayModel(date: '', state: 'upcoming'),
        DailyStreakDayModel(date: '', state: 'upcoming'),
        DailyStreakDayModel(date: '', state: 'upcoming'),
      ];

      final aligned = alignStreakWeek(week);
      expect(aligned[0].isCompleted, isTrue);
      expect(aligned[1].isCompleted, isTrue);
      expect(aligned[2].isUpcoming, isTrue);
    });
  });

  group('sanitizeStreakWeek', () {
    test('clears missed days for brand-new users', () {
      const week = [
        DailyStreakDayModel(date: '2026-05-16', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-17', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-18', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-19', state: 'today_pending'),
        DailyStreakDayModel(date: '2026-05-20', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-21', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-22', state: 'upcoming'),
      ];

      final sanitized = sanitizeStreakWeek(week, today: '2026-05-19');

      expect(sanitized.every((d) => !d.isMissed), isTrue);
      expect(sanitized[0].isUpcoming, isTrue);
      expect(sanitized[3].isToday, isTrue);
    });

    test('keeps missed days after streak activity started', () {
      const week = [
        DailyStreakDayModel(date: '2026-05-16', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-17', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-18', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-19', state: 'today_pending'),
        DailyStreakDayModel(date: '2026-05-20', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-21', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-22', state: 'upcoming'),
      ];

      final sanitized = sanitizeStreakWeek(
        week,
        currentStreak: 2,
        longestStreak: 5,
        today: '2026-05-19',
      );

      expect(sanitized[1].isMissed, isTrue);
      expect(sanitized[0].isCompleted, isTrue);
    });

    test('clears missed days before first completed day in week', () {
      const week = [
        DailyStreakDayModel(date: '2026-05-16', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-17', state: 'past_done'),
        DailyStreakDayModel(date: '2026-05-18', state: 'past_missed'),
        DailyStreakDayModel(date: '2026-05-19', state: 'today_pending'),
        DailyStreakDayModel(date: '2026-05-20', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-21', state: 'upcoming'),
        DailyStreakDayModel(date: '2026-05-22', state: 'upcoming'),
      ];

      final sanitized = sanitizeStreakWeek(
        week,
        currentStreak: 1,
        longestStreak: 1,
        today: '2026-05-19',
      );

      expect(sanitized[0].isUpcoming, isTrue);
      expect(sanitized[1].isCompleted, isTrue);
      expect(sanitized[2].isMissed, isTrue);
    });
  });
}
