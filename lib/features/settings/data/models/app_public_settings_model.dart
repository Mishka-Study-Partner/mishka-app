/// `GET /public/app-settings` — privacy text and support contact fields.
class AppPublicSettingsModel {
  const AppPublicSettingsModel({
    required this.id,
    required this.privacyPolicyText,
    this.supportEmail,
    this.supportPhone,
    this.supportFacebookUrl,
    this.supportInstagramUrl,
    this.updatedAt,
  });

  final String id;
  final String privacyPolicyText;
  final String? supportEmail;
  final String? supportPhone;
  final String? supportFacebookUrl;
  final String? supportInstagramUrl;
  final String? updatedAt;

  bool get hasPrivacyText => privacyPolicyText.trim().isNotEmpty;

  bool get hasSupportContacts =>
      _nonEmpty(supportEmail) ||
      _nonEmpty(supportPhone) ||
      _nonEmpty(supportFacebookUrl) ||
      _nonEmpty(supportInstagramUrl);

  factory AppPublicSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppPublicSettingsModel(
      id: (json['id'] ?? 'default').toString(),
      privacyPolicyText: (json['privacyPolicyText'] ?? '').toString(),
      supportEmail: json['supportEmail'] as String?,
      supportPhone: json['supportPhone'] as String?,
      supportFacebookUrl: json['supportFacebookUrl'] as String?,
      supportInstagramUrl: json['supportInstagramUrl'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  static AppPublicSettingsModel? tryParseEnvelopeData(Object? raw) {
    if (raw is Map) {
      return AppPublicSettingsModel.fromJson(Map<String, dynamic>.from(raw));
    }
    return null;
  }

  static bool _nonEmpty(String? v) => v != null && v.trim().isNotEmpty;
}
