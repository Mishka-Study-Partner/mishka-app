import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/core/network/api_envelope.dart';

void main() {
  test('ApiEnvelope parses backend success shape', () {
    final envelope = ApiEnvelope<Map<String, dynamic>>.fromJson(
      {
        'success': true,
        'message': 'OK',
        'message_en': 'OK',
        'message_ar': 'تم',
        'data': {'accessToken': 't', 'tokenType': 'Bearer', 'user': <String, dynamic>{}},
        'error': null,
        'details': null,
      },
      (raw) => Map<String, dynamic>.from(raw! as Map),
    );

    expect(envelope.success, isTrue);
    expect(envelope.messageAr, 'تم');
    expect(envelope.data?['accessToken'], 't');
  });
}
