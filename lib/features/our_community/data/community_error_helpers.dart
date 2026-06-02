import 'package:mishka_app/core/network/api_exception.dart';

String communityErrorMessage(Object error) {
  if (error is ApiException) {
    final code = error.statusCode;
    if (code == 502 || error.message.toLowerCase().contains('ngrok')) {
      return 'Could not reach the server. Check that the backend is running.';
    }
    if (error.message.isNotEmpty) return error.message;
  }
  final text = error.toString();
  if (text.contains('502') || text.toLowerCase().contains('ngrok')) {
    return 'Could not reach the server. Check that the backend is running.';
  }
  return text;
}
