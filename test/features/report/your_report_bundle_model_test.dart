import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/models/your_report_bundle_model.dart';

void main() {
  group('YourReportBundleModel', () {
    test('parses weekly bundle and maps to snapshot', () {
      final model = YourReportBundleModel.fromJson({
        'period': 'weekly',
        'periodLabel': 'May 19, 2026 – May 25, 2026',
        'rangeStart': '2026-05-19T00:00:00.000Z',
        'rangeEnd': '2026-05-26T00:00:00.000Z',
        'study': {
          'buckets': [
            {'label': 'Mon', 'studyMinutes': 45},
            {'label': 'Tue', 'value': 0},
          ],
        },
        'aiTools': {
          'quizzes': 3,
          'flashcards': 5,
          'summaries': 1,
          'mindMaps': 0,
        },
        'streak': {
          'currentStreak': 5,
          'longestStreak': 14,
          'freezesRemaining': 2,
          'week': [
            {
              'date': '2026-05-19',
              'state': 'past_done',
              'isCompleted': true,
              'isToday': false,
            },
          ],
        },
        'tasksCompleted': {
          'buckets': [
            {'label': 'Mon', 'completedCount': 2},
            {'label': '2026-05-20', 'completedCount': 1},
          ],
        },
      });

      expect(model.period, ReportPeriod.weekly);
      expect(model.studyMinutes.first.value, 45);
      expect(model.aiTools.quizzes, 3);
      expect(model.currentStreak, 5);
      expect(model.tasksCompletedByDay.first.value, 2);
      expect(model.tasksCompletedByDay[1].label, 'Wed');

      final snapshot = model.toSnapshot();
      expect(snapshot.dataSource, ReportDataSource.bundle);
      expect(snapshot.hasStreakWeek, isFalse);
    });

    test('converts ISO task bucket labels to weekday abbreviations', () {
      final model = YourReportBundleModel.fromJson({
        'period': 'weekly',
        'periodLabel': 'Test',
        'rangeStart': '2026-05-19T00:00:00.000Z',
        'rangeEnd': '2026-05-26T00:00:00.000Z',
        'tasksCompleted': {
          'buckets': [
            {'label': '2026-05-19', 'completedCount': 1},
            {'label': 'Fri', 'completedCount': 2},
          ],
        },
      });

      expect(model.tasksCompletedByDay[0].label, 'Tue');
      expect(model.tasksCompletedByDay[1].label, 'Fri');
    });
  });
}
