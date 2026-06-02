import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/utils/link_launcher.dart';
import 'package:mishka_app/features/report/data/data_sources/your_report_remote_data_source.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/models/your_report_bundle_model.dart';
import 'package:mishka_app/features/report/presentation/services/report_local_pdf_builder.dart';

enum ReportExportMode { server, localFallback }

class ReportExportOutcome {
  const ReportExportOutcome.server(this.result)
      : mode = ReportExportMode.server,
        localFile = null;

  const ReportExportOutcome.localFallback(this.localFile)
      : mode = ReportExportMode.localFallback,
        result = null;

  final ReportExportMode mode;
  final ReportExportResult? result;
  final File? localFile;
}

class ReportPdfService {
  ReportPdfService({
    YourReportRemoteDataSource? remote,
    ReportLocalPdfBuilder? localBuilder,
  })  : _remote = remote ?? YourReportRemoteDataSource(ApiService()),
        _local = localBuilder ?? ReportLocalPdfBuilder();

  final YourReportRemoteDataSource _remote;
  final ReportLocalPdfBuilder _local;

  Future<ReportExportOutcome> exportReport({
    required ReportPeriod period,
    required DateTime anchorDate,
    required String locale,
    required YourReportSnapshot snapshot,
    required String title,
    required String studySectionTitle,
    required String aiSectionTitle,
    required String streakSectionTitle,
    required String tasksSectionTitle,
    required String streakCurrentLabel,
    required String streakLongestLabel,
    required String streakFreezesLabel,
    required String quizzesLabel,
    required String flashcardsLabel,
    required String summariesLabel,
    String delivery = 'both',
    String? emailTo,
    bool useCustomRecipient = false,
  }) async {
    try {
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
      return ReportExportOutcome.server(result);
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('📊 YourReport PDF server failed, local fallback: $e\n$st');
      }
      final file = await _local.buildAndSave(
        snapshot: snapshot,
        title: title,
        studySectionTitle: studySectionTitle,
        aiSectionTitle: aiSectionTitle,
        streakSectionTitle: streakSectionTitle,
        tasksSectionTitle: tasksSectionTitle,
        streakCurrentLabel: streakCurrentLabel,
        streakLongestLabel: streakLongestLabel,
        streakFreezesLabel: streakFreezesLabel,
        quizzesLabel: quizzesLabel,
        flashcardsLabel: flashcardsLabel,
        summariesLabel: summariesLabel,
      );
      return ReportExportOutcome.localFallback(file);
    }
  }

  Future<bool> openPdfUrl(String? url) async {
    if (url == null || url.trim().isEmpty) return false;
    return LinkLauncher.openUrl(url);
  }

  Future<void> shareLocalFile(File file, {String? subject}) async {
    await _local.shareFile(file, subject: subject);
  }
}
