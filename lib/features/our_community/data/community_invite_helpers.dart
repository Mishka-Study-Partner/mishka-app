import 'package:mishka_app/features/Auth/data/models/user_model.dart';

/// Normalizes invite username input (trim, strip leading `@`).
String normalizeInviteUsername(String raw) {
  var value = raw.trim();
  while (value.startsWith('@')) {
    value = value.substring(1).trim();
  }
  return value;
}

/// Whether [target] is the signed-in user (cannot direct-invite yourself).
bool isSelfInviteTarget(String target, UserModel? currentUser) {
  if (target.isEmpty || currentUser == null) return false;
  final normalized = target.trim().toLowerCase();
  final username = (currentUser.username ?? '').trim().toLowerCase();
  final email = currentUser.email.trim().toLowerCase();
  return normalized == username || normalized == email;
}
