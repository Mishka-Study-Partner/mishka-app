import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// User-facing auth API errors (no raw Dio / status codes).
class AuthErrorMessages {
  AuthErrorMessages._();

  static String from(Object error, AppLocalizations l10n) {
    if (error is ApiException) {
      if (error.error == 'UNIQUE_VIOLATION') {
        return l10n.accountAlreadyExists;
      }
      if (_isNetworkFailure(error)) {
        return l10n.networkConnectionError;
      }
      return error.userMessage;
    }
    return l10n.networkConnectionError;
  }

  static bool _isNetworkFailure(ApiException error) {
    if (error.error == 'NETWORK_ERROR') return true;
    final msg = error.message.toLowerCase();
    return msg.contains('failed host lookup') ||
        msg.contains('network is unreachable') ||
        msg.contains('connection errored') ||
        msg.contains('connection refused') ||
        msg.contains('connection timed out') ||
        msg.contains('socketexception');
  }
}
