import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';

class ReportRemoteDataSource {
  ReportRemoteDataSource(this._api);

  final ApiService _api;

  static const _allModes = 'all';
  static const _legacyModes = ['concentration', 'call_with_mishka'];

  Future<StudyPeriodReport> getDayReport(DateTime date) async {
    return _getCombinedOrLegacy(
      () => _getDayReport(date, _allModes),
      () => _mergeLegacyDay(date),
    );
  }

  Future<StudyPeriodReport> getWeekReport(DateTime dateInWeek) async {
    return _getCombinedOrLegacy(
      () => _getWeekReport(dateInWeek, _allModes),
      () => _mergeLegacyWeek(dateInWeek),
    );
  }

  Future<StudyPeriodReport> getMonthReport(int year, int month) async {
    return _getCombinedOrLegacy(
      () => _getMonthReport(year, month, _allModes),
      () => _mergeLegacyMonth(year, month),
    );
  }

  Future<StudyPeriodReport> _getCombinedOrLegacy(
    Future<StudyPeriodReport> Function() combined,
    Future<StudyPeriodReport> Function() legacy,
  ) async {
    try {
      return await combined();
    } catch (_) {
      return legacy();
    }
  }

  Future<StudyPeriodReport> _mergeLegacyDay(DateTime date) async {
    return _mergeReports(
      await Future.wait(_legacyModes.map((m) => _getDayReport(date, m))),
    );
  }

  Future<StudyPeriodReport> _mergeLegacyWeek(DateTime dateInWeek) async {
    return _mergeReports(
      await Future.wait(_legacyModes.map((m) => _getWeekReport(dateInWeek, m))),
    );
  }

  Future<StudyPeriodReport> _mergeLegacyMonth(int year, int month) async {
    return _mergeReports(
      await Future.wait(
        _legacyModes.map((m) => _getMonthReport(year, month, m)),
      ),
    );
  }

  Future<StudyPeriodReport> _getDayReport(
    DateTime date,
    String topLevelMode,
  ) async {
    final env = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.studyWithMishkaReportsDay,
      queryParameters: {
        'date': _utcDateString(date),
        'topLevelMode': topLevelMode,
      },
      dataFromJson: _mapFromRaw,
    );
    return _parsePeriodReport(env.data);
  }

  Future<StudyPeriodReport> _getWeekReport(
    DateTime dateInWeek,
    String topLevelMode,
  ) async {
    final env = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.studyWithMishkaReportsWeek,
      queryParameters: {
        'date': _utcDateString(dateInWeek),
        'topLevelMode': topLevelMode,
      },
      dataFromJson: _mapFromRaw,
    );
    return _parsePeriodReport(env.data);
  }

  Future<StudyPeriodReport> _getMonthReport(
    int year,
    int month,
    String topLevelMode,
  ) async {
    final env = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.studyWithMishkaReportsMonth,
      queryParameters: {
        'year': year,
        'month': month,
        'topLevelMode': topLevelMode,
      },
      dataFromJson: _mapFromRaw,
    );
    return _parsePeriodReport(env.data);
  }

  StudyPeriodReport _mergeReports(List<StudyPeriodReport> reports) {
    return reports.fold(
      const StudyPeriodReport(),
      (combined, report) => combined.merge(report),
    );
  }

  StudyPeriodReport _parsePeriodReport(Map<String, dynamic>? data) {
    if (data == null) return const StudyPeriodReport();
    final totals = data['totals'];
    final seconds = totals is Map
        ? _parseInt(
            totals['sumApproximateMainStudySeconds'] ??
                totals['sumStudySeconds'] ??
                totals['sumMainStudySeconds'],
          )
        : 0;
    final summariesRaw = (data['sessionSummaries'] as List?) ?? const [];
    final summaries = summariesRaw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
    return StudyPeriodReport(
      sumStudySeconds: seconds,
      sessionSummaries: summaries,
    );
  }

  String _utcDateString(DateTime date) {
    final utc = DateTime.utc(date.year, date.month, date.day);
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Map<String, dynamic> _mapFromRaw(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    throw const FormatException('Invalid report response');
  }

  int _parseInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
