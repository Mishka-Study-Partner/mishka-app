import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

String communityErrorMessage(
  Object error, {
  AppLocalizations? l10n,
}) {
  if (error is ApiException) {
    if (error.error == 'INVITE_USER_NOT_FOUND') {
      if (error.message.isNotEmpty) return error.message;
      return l10n?.communityInviteUserNotFound ??
          'No Mishka account found for that email or username.';
    }
    if (error.error == 'INVITE_SELF_NOT_ALLOWED') {
      if (error.message.isNotEmpty) return error.message;
      return l10n?.communityInviteCannotInviteSelf ??
          'You cannot invite yourself.';
    }
    if (error.error == 'VALIDATION_ERROR') {
      final details = error.details;
      if (details is List && details.isNotEmpty) {
        final first = details.first;
        if (first is Map && first['message'] != null) {
          return first['message'].toString();
        }
      }
      if (l10n != null && _looksLikeSelfInviteValidation(error)) {
        return l10n.communityInviteCannotInviteSelf;
      }
    }
    final code = error.statusCode;
    if (code == 502 || error.message.toLowerCase().contains('ngrok')) {
      return l10n?.communityErrorServerUnreachable ??
          'Could not reach the server. Check that the backend is running.';
    }
    if (error.message.isNotEmpty) return error.message;
  }
  final text = error.toString();
  if (text.contains('502') || text.toLowerCase().contains('ngrok')) {
    return l10n?.communityErrorServerUnreachable ??
        'Could not reach the server. Check that the backend is running.';
  }
  return text;
}

bool _looksLikeSelfInviteValidation(ApiException error) {
  if (error.details != null) return false;
  return error.message.toLowerCase() == 'validation failed';
}
