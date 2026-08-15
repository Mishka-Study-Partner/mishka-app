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
          'totals': {'sumStudyMinutes': 180},
          'bySubject': [
            {
              'studentSubjectId': 'sub-1',
              'name': 'Physics',
              'color': '#4E7DBA',
              'studyMinutes': 120,
              'sessionCount': 8,
              'percentOfTotal': 67,
            },
            {
              'studentSubjectId': null,
              'name': 'Unassigned',
              'color': null,
              'studyMinutes': 60,
              'sessionCount': 2,
              'percentOfTotal': 33,
            },
          ],
        },
        'aiTools': {
          'quizzes': 3,
          'flashcards': 5,
          'summaries': 1,
          'mindMaps': 0,
          'rings': [
            {'key': 'quizzes', 'count': 3, 'percent': 43},
            {'key': 'flashcards', 'count': 5, 'percent': 71},
            {'key': 'summaries', 'count': 1, 'percent': 14},
          ],
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
      expect(model.totalStudyMinutes, 180);
      expect(model.studyBySubject, hasLength(2));
      expect(model.studyBySubject.first.name, 'Physics');
      expect(model.studyBySubject.first.studyMinutes, 120);
      expect(model.aiTools.quizzes, 3);
      expect(model.aiTools.percentForKey('quizzes', ReportPeriod.weekly), 43);
      expect(model.currentStreak, 5);
      expect(model.tasksCompletedByDay.first.value, 2);
      expect(model.tasksCompletedByDay[1].label, 'Wed');

      final snapshot = model.toSnapshot();
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
