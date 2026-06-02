// ignore_for_file: avoid_print
/// Redirect — do not run with `dart run` from the Flutter project root.
///
/// From repo root use:
///   TEST_EMAIL=you@example.com TEST_PASSWORD=yourpassword \
///     ./tool/verify_community_backend_fixes.sh
///
/// `dart run tool/verify_community_backend_fixes.dart` fails because the app
/// package pulls in Flutter plugins (native_assets / objective_c).
import 'dart:io';

void main() {
  stderr.writeln(
    'Run from repo root:\n'
    '  TEST_EMAIL=you@example.com TEST_PASSWORD=yourpassword '
    './tool/verify_community_backend_fixes.sh\n',
  );
  exit(1);
}
