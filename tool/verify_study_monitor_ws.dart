// Smoke test for ML StudyMonitor WebSocket (Integration.pdf).
//
// Usage:
//   dart run tool/verify_study_monitor_ws.dart
//   ML_SERVICE_BASE_URL=https://your-host dart run tool/verify_study_monitor_ws.dart
//
// Sends a minimal JPEG; expects JSON {"status": "..."}.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:web_socket_channel/io.dart';

void main() async {
  const baseUrl = String.fromEnvironment(
    'ML_SERVICE_BASE_URL',
    defaultValue: 'https://study-monitor-model-production.up.railway.app',
  );
  final parsed = Uri.parse(baseUrl);
  final wsUri = parsed.replace(
    scheme: parsed.scheme == 'https' ? 'wss' : 'ws',
    path: '/ws/study-session',
    query: null,
    fragment: null,
  );

  stdout.writeln('Connecting to $wsUri …');

  final channel = IOWebSocketChannel.connect(
    wsUri,
    headers: const {'ngrok-skip-browser-warning': 'true'},
  );

  // Minimal valid JPEG (1x1 pixel).
  const jpegHex =
      'ffd8ffe000104a46494600010100000100010000ffdb004300080606070605080707070909080a0c140d0c0b0b0c1912130f141d1a1f1e1d1a1c1c20242e2720222c231c1c2837292c30313434341f27393d38323c2e333432ffdb0043010909090c0b0c180d0d1832211c213232323232323232323232323232323232323232323232323232323232323232323232323232323232323232323232ffc0000b0800010000010100110002ffc40014000100000000000000000000000000000000ffc40014100100000000000000000000000000000000ffda0008010100003f00d2cf20ffd9';
  final bytes = List<int>.generate(
    jpegHex.length ~/ 2,
    (i) => int.parse(jpegHex.substring(i * 2, i * 2 + 2), radix: 16),
  );

  final completer = Completer<void>();
  channel.stream.listen(
    (message) {
      stdout.writeln('Response: $message');
      try {
        final map = jsonDecode(message as String) as Map<String, dynamic>;
        final status = map['status'];
        if (status == null) {
          stderr.writeln('FAIL: missing "status" field');
          exit(1);
        }
        stdout.writeln('OK: status=$status');
        completer.complete();
      } catch (e) {
        stderr.writeln('FAIL: invalid JSON ($e)');
        exit(1);
      }
    },
    onError: (Object e) {
      stderr.writeln('FAIL: WebSocket error: $e');
      exit(1);
    },
    onDone: () {
      if (!completer.isCompleted) {
        stderr.writeln('FAIL: connection closed before response');
        exit(1);
      }
    },
  );

  channel.sink.add(bytes);
  await completer.future.timeout(
    const Duration(seconds: 15),
    onTimeout: () {
      stderr.writeln('FAIL: timeout waiting for ML response');
      exit(1);
    },
  );
  await channel.sink.close();
  stdout.writeln('StudyMonitor WebSocket smoke test passed.');
}
