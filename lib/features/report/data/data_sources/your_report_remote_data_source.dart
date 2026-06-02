import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/report/data/models/report_models.dart';
import 'package:mishka_app/features/report/data/models/your_report_bundle_model.dart';

class YourReportRemoteDataSource {
  YourReportRemoteDataSource(this._api);

  final ApiService _api;

  Future<YourReportBundleModel> getBundle({
    required ReportPeriod period,
    required DateTime anchorDate,
    required String locale,
  }) async {
    final env = await _api.get<Map<String, dynamic>>(
      ApiEndpoints.yourReport,
      queryParameters: {
        'period': period.name,
        'date': _dateString(anchorDate),
        'locale': locale,
        'format': 'bundle',
      },
      dataFromJson: (raw) {
        if (raw is Map) return Map<String, dynamic>.from(raw);
        throw const FormatException('Invalid your-report response');
      },
    );
    final data = env.data;
    if (data == null) throw const FormatException('Empty your-report response');
    return YourReportBundleModel.fromJson(data);
  }

  Future<ReportExportResult> exportReport({
    required ReportPeriod period,
    required DateTime anchorDate,
    required String locale,
    required String delivery,
    String? emailTo,
    bool useCustomRecipient = false,
  }) async {
    final body = {
      'period': period.name,
      'anchorDate': _dateString(anchorDate),
      'locale': locale,
      'delivery': delivery,
    };
    _applyRecipient(body, emailTo: emailTo, useCustomRecipient: useCustomRecipient);

    try {
      return await _postExport(body);
    } on ApiException catch (e) {
      if (delivery != 'download' && _isEmailNotConfigured(e)) {
        final downloadBody = Map<String, dynamic>.from(body)
          ..['delivery'] = 'download';
        return _postExport(downloadBody);
      }
      rethrow;
    }
  }

  bool _isEmailNotConfigured(ApiException e) {
    return e.error == 'REPORT_EXPORT_EMAIL_NOT_CONFIGURED';
  }

  void _applyRecipient(
    Map<String, dynamic> body, {
    required String? emailTo,
    required bool useCustomRecipient,
  }) {
    final recipient = emailTo?.trim();
    if (useCustomRecipient && recipient != null && recipient.isNotEmpty) {
      body['emailRecipient'] = 'custom';
      body['emailTo'] = recipient;
      return;
    }
    body['emailRecipient'] = 'account';
  }

  Future<ReportExportResult> _postExport(Map<String, dynamic> body) async {
    final env = await _api.post<Map<String, dynamic>>(
      ApiEndpoints.yourReportExport,
      data: body,
      dataFromJson: (raw) {
        if (raw is Map) return Map<String, dynamic>.from(raw);
        throw const FormatException('Invalid export response');
      },
    );
    final data = env.data;
    if (data == null) throw const FormatException('Empty export response');
    return ReportExportResult.fromJson(data);
  }

  String _dateString(DateTime date) {
    final utc = date.toUtc();
    final y = utc.year.toString().padLeft(4, '0');
    final m = utc.month.toString().padLeft(2, '0');
    final d = utc.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
