class GamificationCollectResult {
  const GamificationCollectResult({
    required this.success,
    required this.created,
    required this.badgeCode,
    required this.timesEarnedThisWeek,
    required this.timesEarnedThisMonth,
  });

  final bool success;
  final bool created;
  final String badgeCode;
  final int timesEarnedThisWeek;
  final int timesEarnedThisMonth;

  factory GamificationCollectResult.fromJson(Map<String, dynamic> json) {
    return GamificationCollectResult(
      success: json['success'] == true,
      created: json['created'] != false,
      badgeCode: (json['badgeCode'] ?? '').toString(),
      timesEarnedThisWeek: _int(json['timesEarnedThisWeek']),
      timesEarnedThisMonth: _int(json['timesEarnedThisMonth']),
    );
  }

  static int _int(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
