import 'package:mishka_app/l10n/app_localizations.dart';

/// Client-side validators aligned with backend registration rules.
class AuthValidators {
  AuthValidators._();

  static String? validateFirstName(String? value, AppLocalizations l10n) {
    return _validatePersonName(value, l10n);
  }

  static String? validateLastName(String? value, AppLocalizations l10n) {
    return _validatePersonName(value, l10n);
  }

  static String? _validatePersonName(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.fieldRequired;
    if (trimmed.length > 50) return l10n.nameTooLong;
    return null;
  }

  static String? validateEmail(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.fieldRequired;
    final at = trimmed.indexOf('@');
    if (at < 1) return l10n.invalidEmailHint;
    final domain = trimmed.substring(at + 1);
    final dot = domain.lastIndexOf('.');
    final validDomain = dot > 0 && dot < domain.length - 1;
    final hasSpace = trimmed.contains(' ') || trimmed.contains('\t');
    if (!validDomain || hasSpace) return l10n.invalidEmailHint;
    return null;
  }

  static String? validatePhone(String? value, AppLocalizations l10n) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return l10n.fieldRequired;
    final digits = trimmed.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 7 || digits.length > 15) {
      return l10n.invalidPhoneHint;
    }
    return null;
  }

  static String? validatePassword(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) return l10n.fieldRequired;
    if (value.length < 8 || value.length > 20) {
      return l10n.passwordRequirement1;
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return l10n.passwordRequirement2;
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return l10n.passwordRequirement3;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\\/`~]').hasMatch(value)) {
      return l10n.passwordRequirement4;
    }
    return null;
  }
}
