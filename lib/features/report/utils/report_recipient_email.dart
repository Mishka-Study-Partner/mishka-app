import 'dart:convert';

import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';
import 'package:mishka_app/features/Auth/data/models/user_model.dart';
import 'package:mishka_app/features/settings/data/data_sources/user_preferences_remote_data_source.dart';
import 'package:mishka_app/features/settings/data/models/report_email_preferences_model.dart';

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

  /// Prefer `GET /user-preferences/me` → `reportEmail`, then local cache.
  static Future<ReportRecipientResolution> resolveAsync() async {
    try {
      final me =
          await UserPreferencesRemoteDataSource(ApiService()).fetchMe();
      if (me != null) {
        return _fromServerPrefs(me.reportEmail);
      }
    } catch (_) {
      // Offline or endpoint unavailable — fall back to cache.
    }
    return resolve();
  }

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

  static ReportRecipientResolution _fromServerPrefs(
    ReportEmailPreferencesModel prefs,
  ) {
    if (prefs.usingCustomRecipient) {
      final custom = prefs.effectiveRecipientEmail?.trim();
      if (custom != null && custom.isNotEmpty) {
        return ReportRecipientResolution(
          email: custom,
          useCustomRecipient: true,
        );
      }
    }
    final account = prefs.accountEmail?.trim() ??
        prefs.effectiveRecipientEmail?.trim() ??
        _accountEmail();
    return ReportRecipientResolution(
      email: account,
      useCustomRecipient: false,
    );
  }

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
