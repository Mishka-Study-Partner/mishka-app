import 'package:flutter/foundation.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/report/data/data_sources/your_report_remote_data_source.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/repositories/report_legacy_loader.dart';

class ReportRepository {
  ReportRepository({
    YourReportRemoteDataSource? remote,
    ReportLegacyLoader? legacy,
  })  : _remote = remote ?? YourReportRemoteDataSource(ApiService()),
        _legacy = legacy ?? ReportLegacyLoader();

  final YourReportRemoteDataSource _remote;
  final ReportLegacyLoader _legacy;

  static const _cacheTtl = Duration(minutes: 2);
  final Map<_CacheKey, _CacheEntry> _cache = {};

  Future<YourReportSnapshot> loadReport(
    ReportPeriod period, {
    bool forceRefresh = false,
    String locale = 'en',
  }) async {
    final key = _CacheKey(period, locale);
    if (!forceRefresh) {
      final cached = _cache[key];
      if (cached != null &&
          DateTime.now().difference(cached.loadedAt) < _cacheTtl) {
        return cached.snapshot;
      }
    }

    final anchor = DateTime.now();
    YourReportSnapshot snapshot;

    try {
      final bundle = await _remote.getBundle(
        period: period,
        anchorDate: anchor,
        locale: locale,
      );
      snapshot = bundle.toSnapshot();
      if (kDebugMode) {
        debugPrint('📊 YourReport: loaded via bundle API');
      }
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('📊 YourReport bundle failed, using legacy: $e\n$st');
      }
      snapshot = await _legacy.loadReport(period);
    }

    _cache[key] = _CacheEntry(snapshot, DateTime.now());
    return snapshot;
  }
}

class _CacheKey {
  const _CacheKey(this.period, this.locale);

  final ReportPeriod period;
  final String locale;

  @override
  bool operator ==(Object other) {
    return other is _CacheKey &&
        other.period == period &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(period, locale);
}

class _CacheEntry {
  const _CacheEntry(this.snapshot, this.loadedAt);

  final YourReportSnapshot snapshot;
  final DateTime loadedAt;
}
