class ReportEmailPreferencesModel {
  const ReportEmailPreferencesModel({
    this.autoEnabled = false,
    this.frequency = 'weekly',
    this.locale = 'en',
    this.recipientEmail,
    this.accountEmail,
    this.usingCustomRecipient = false,
    this.effectiveRecipientEmail,
    this.lastSentAt,
    this.lastPeriodKey,
  });

  final bool autoEnabled;
  final String frequency;
  final String locale;
  final String? recipientEmail;
  final String? accountEmail;
  final bool usingCustomRecipient;
  final String? effectiveRecipientEmail;
  final String? lastSentAt;
  final String? lastPeriodKey;

  bool get hasRecipientEmail =>
      recipientEmail != null && recipientEmail!.trim().isNotEmpty;

  String? get displayRecipientEmail =>
      effectiveRecipientEmail?.trim().isNotEmpty == true
          ? effectiveRecipientEmail!.trim()
          : (hasRecipientEmail ? recipientEmail!.trim() : accountEmail?.trim());

  ReportEmailPreferencesModel copyWith({
    bool? autoEnabled,
    String? frequency,
    String? locale,
    String? recipientEmail,
    String? accountEmail,
    bool? usingCustomRecipient,
    String? effectiveRecipientEmail,
  }) {
    return ReportEmailPreferencesModel(
      autoEnabled: autoEnabled ?? this.autoEnabled,
      frequency: frequency ?? this.frequency,
      locale: locale ?? this.locale,
      recipientEmail: recipientEmail ?? this.recipientEmail,
      accountEmail: accountEmail ?? this.accountEmail,
      usingCustomRecipient: usingCustomRecipient ?? this.usingCustomRecipient,
      effectiveRecipientEmail:
          effectiveRecipientEmail ?? this.effectiveRecipientEmail,
      lastSentAt: lastSentAt,
      lastPeriodKey: lastPeriodKey,
    );
  }

  factory ReportEmailPreferencesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ReportEmailPreferencesModel();
    return ReportEmailPreferencesModel(
      autoEnabled: json['reportEmailAutoEnabled'] == true,
      frequency: (json['reportEmailFrequency'] ?? 'weekly').toString(),
      locale: (json['reportEmailLocale'] ?? 'en').toString(),
      recipientEmail: _readRecipient(json),
      accountEmail: json['accountEmail']?.toString(),
      usingCustomRecipient: json['usingCustomRecipient'] == true,
      effectiveRecipientEmail: json['effectiveRecipientEmail']?.toString(),
      lastSentAt: json['reportEmailLastSentAt']?.toString(),
      lastPeriodKey: json['reportEmailLastPeriodKey']?.toString(),
    );
  }

  static String? _readRecipient(Map<String, dynamic> json) {
    final raw = json['reportEmailRecipient'] ?? json['recipientEmail'];
    if (raw == null) return null;
    final text = raw.toString().trim();
    return text.isEmpty ? null : text;
  }

  /// Partial PATCH body — only includes fields you pass explicitly.
  Map<String, dynamic> toPatchJson({
    bool? autoEnabled,
    String? frequency,
    String? locale,
    String? recipientEmail,
  }) {
    final body = <String, dynamic>{};
    final enabled = autoEnabled ?? this.autoEnabled;

    if (autoEnabled != null) {
      body['reportEmailAutoEnabled'] = autoEnabled;
    }
    if (autoEnabled != null || frequency != null) {
      if (enabled) {
        body['reportEmailFrequency'] = frequency ?? this.frequency;
      }
    }
    if (autoEnabled != null || locale != null) {
      if (enabled) {
        body['reportEmailLocale'] = locale ?? this.locale;
      }
    }
    if (recipientEmail != null) {
      body['reportEmailRecipient'] = recipientEmail.trim();
    } else if (hasRecipientEmail &&
        (autoEnabled != null || frequency != null || locale != null)) {
      body['reportEmailRecipient'] = this.recipientEmail!.trim();
    }
    return body;
  }

  static Map<String, dynamic> patchRecipientOnly(String email) {
    return {'reportEmailRecipient': email.trim()};
  }
}
