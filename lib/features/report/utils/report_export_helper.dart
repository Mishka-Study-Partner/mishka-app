import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Maps Your Report export API errors to user-facing strings.
class ReportExportHelper {
  ReportExportHelper._();

  static String userMessage(AppLocalizations l10n, Object error) {
    if (error is ApiException) {
      return switch (error.error) {
        'REPORT_NO_DATA' => l10n.reportExportNoData,
        'REPORT_EXPORT_EMAIL_NOT_CONFIGURED' =>
          l10n.reportExportEmailNotConfigured,
        'VALIDATION_ERROR' => error.message,
        _ => error.message.isNotEmpty
            ? error.message
            : l10n.reportPdfFailed(error.error ?? error.toString()),
      };
    }
    return l10n.reportPdfFailed(error.toString());
  }
}
