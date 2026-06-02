import 'dart:convert';

import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';

class ReportRecipientResolution {
  const ReportRecipientResolution({
    required this.email,
    required this.useCustomRecipient,
  });

  final String? email;
  final bool useCustomRecipient;
}

/// Resolves the email used for report export / auto-send.
class ReportRecipientEmail {
  ReportRecipientEmail._();

  static ReportRecipientResolution resolve() {
    final saved = AppPreferences.reportEmailRecipient?.trim();
    if (saved != null && saved.isNotEmpty) {
      return ReportRecipientResolution(
        email: saved,
        useCustomRecipient: true,
      );
    }

    final account = _accountEmail();
    return ReportRecipientResolution(
      email: account,
      useCustomRecipient: false,
    );
  }

  static String? resolveEmail() => resolve().email;

  static String? _accountEmail() {
    final raw = AppPreferences.cachedUserJson;
    if (raw == null || raw.isEmpty) return null;
    try {
      final user = UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      final account = user.email.trim();
      return account.isEmpty ? null : account;
    } catch (_) {
      return null;
    }
  }
}
