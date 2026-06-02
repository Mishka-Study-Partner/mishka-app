import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens mail, WhatsApp, phone, and web URLs in platform apps.
class LinkLauncher {
  LinkLauncher._();

  static Future<bool> openUrl(String raw) async {
    final uri = _parseHttpUri(raw);
    if (uri == null) return false;
    return _tryLaunch(uri, modes: const [LaunchMode.externalApplication]);
  }

  static Future<bool> openEmail(String email) async {
    final address = email.trim();
    if (address.isEmpty) return false;

    // Gmail web compose — works on simulator and when no Mail app is installed.
    final gmailWeb = Uri.https(
      'mail.google.com',
      '/mail/',
      <String, String>{
        'view': 'cm',
        'fs': '1',
        'to': address,
      },
    );
    if (await _tryLaunch(
      gmailWeb,
      modes: const [LaunchMode.externalApplication],
    )) {
      return true;
    }

    // Fallback: native Mail / default email handler.
    final mailto = Uri(scheme: 'mailto', path: address);
    return _tryLaunch(
      mailto,
      modes: const [
        LaunchMode.platformDefault,
        LaunchMode.externalApplication,
      ],
    );
  }

  /// Opens WhatsApp chat for [phone] (`wa.me`), then `whatsapp://`, then `tel:`.
  static Future<bool> openWhatsApp(String phone) async {
    final digits = _digitsForWhatsApp(phone);
    if (digits.isEmpty) return false;

    final waWeb = Uri.parse('https://wa.me/$digits');
    if (await _tryLaunch(
      waWeb,
      modes: const [LaunchMode.externalApplication],
    )) {
      return true;
    }

    final waApp = Uri.parse('whatsapp://send?phone=$digits');
    if (await _tryLaunch(
      waApp,
      modes: const [LaunchMode.externalApplication],
    )) {
      return true;
    }

    final tel = _digitsWithPlus(phone);
    if (tel.isEmpty) return false;
    return _tryLaunch(
      Uri(scheme: 'tel', path: tel),
      modes: const [LaunchMode.platformDefault],
    );
  }

  static String displayLabelForUrl(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty) return url.trim();
    final host = uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
    return host;
  }

  static Future<bool> _tryLaunch(
    Uri uri, {
    required List<LaunchMode> modes,
  }) async {
    for (final mode in modes) {
      try {
        final launched = await launchUrl(uri, mode: mode);
        if (launched) return true;
      } catch (e, st) {
        debugPrint('LinkLauncher: $uri mode=$mode failed: $e\n$st');
      }
    }
    return false;
  }

  static Uri? _parseHttpUri(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;
    if (uri.hasScheme) return uri;
    return Uri.tryParse('https://$trimmed');
  }

  /// Digits only, no leading `+` (required by wa.me).
  static String _digitsForWhatsApp(String phone) {
    final buf = StringBuffer();
    for (final unit in phone.trim().runes) {
      if (unit >= 0x30 && unit <= 0x39) buf.writeCharCode(unit);
    }
    return buf.toString();
  }

  static String _digitsWithPlus(String phone) {
    final digits = _digitsForWhatsApp(phone);
    if (digits.isEmpty) return '';
    return '+$digits';
  }
}
