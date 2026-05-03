/// Matches backend JSON envelope: `success`, `message`, `message_en`, `message_ar`, `data`, `error`, `details`.
class ApiEnvelope<T> {
  const ApiEnvelope({
    required this.success,
    required this.message,
    required this.messageEn,
    required this.messageAr,
    this.data,
    this.error,
    this.details,
  });

  final bool success;
  final String message;
  final String messageEn;
  final String messageAr;
  final T? data;
  final String? error;
  final dynamic details;

  factory ApiEnvelope.fromJson(
    Map<String, dynamic> json,
    T? Function(Object? json)? dataFromJson,
  ) {
    final raw = json['data'];
    final T? data = dataFromJson != null ? dataFromJson(raw) : null;

    return ApiEnvelope<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      messageEn: json['message_en'] as String? ?? '',
      messageAr: json['message_ar'] as String? ?? '',
      data: data,
      error: json['error'] as String?,
      details: json['details'],
    );
  }
}
