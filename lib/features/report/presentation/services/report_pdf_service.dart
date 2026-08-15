import 'package:flutter/foundation.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/link_launcher.dart';
import 'package:mishka_app/features/report/data/data_sources/your_report_remote_data_source.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/models/your_report_bundle_model.dart';

/// Server-side PDF export via `POST /reports/your-report/export`.
class ReportPdfService {
  ReportPdfService({YourReportRemoteDataSource? remote})
      : _remote = remote ?? YourReportRemoteDataSource(ApiService());

  final YourReportRemoteDataSource _remote;

  Future<ReportExportResult> exportReport({
    required ReportPeriod period,
    required DateTime anchorDate,
    required String locale,
    String delivery = 'both',
    String? emailTo,
    bool useCustomRecipient = false,
  }) async {
    final result = await _remote.exportReport(
      period: period,
      anchorDate: anchorDate,
      locale: locale,
      delivery: delivery,
      emailTo: emailTo,
      useCustomRecipient: useCustomRecipient,
    );
    if (kDebugMode) {
      debugPrint('📊 YourReport PDF: server export OK');
    }
    return result;
  }

  Future<bool> openPdfUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return false;
    return LinkLauncher.openUrl(url);
  }
}
