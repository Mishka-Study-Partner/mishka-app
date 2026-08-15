import 'package:flutter/material.dart';

/// Parsed ML WebSocket response (`status` + optional `color_bgr`).
class StudyMonitorResponse {
  const StudyMonitorResponse({
    required this.status,
    required this.kind,
    this.colorBgr,
    this.message,
  });

  final String status;
  final StudyPostureKind kind;
  final List<int>? colorBgr;
  final String? message;

  Color? get indicatorColor {
    final bgr = colorBgr;
    if (bgr == null || bgr.length < 3) return null;
    return Color.fromARGB(255, bgr[2], bgr[1], bgr[0]);
  }

  factory StudyMonitorResponse.fromJson(Map<String, dynamic> json) {
    final status = (json['status'] ?? '').toString().trim();
    final message = json['message']?.toString();
    List<int>? colorBgr;
    final rawColor = json['color_bgr'];
    if (rawColor is List) {
      colorBgr = rawColor
          .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
          .toList();
    }
    return StudyMonitorResponse(
      status: status,
      kind: StudyPostureKind.fromStatus(status),
      colorBgr: colorBgr,
      message: message,
    );
  }
}

enum StudyPostureKind {
  calibrating,
  focusing,
  badPosture,
  lookingAway,
  noUser,
  error,
  unknown;

  static StudyPostureKind fromStatus(String raw) {
    final s = raw.toUpperCase();
    if (s.contains('CALIBRATING')) return StudyPostureKind.calibrating;
    if (s == 'FOCUSING' || s.contains('FOCUSING')) return StudyPostureKind.focusing;
    if (s.contains('BAD POSTURE')) return StudyPostureKind.badPosture;
    if (s.contains('LOOKING AWAY')) return StudyPostureKind.lookingAway;
    if (s.contains('NO USER')) return StudyPostureKind.noUser;
    if (s == 'ERROR' || s.contains('ERROR')) return StudyPostureKind.error;
    return StudyPostureKind.unknown;
  }

  /// Orange alert states (bad posture / looking away).
  bool get isWarningAlert =>
      this == StudyPostureKind.badPosture ||
      this == StudyPostureKind.lookingAway;

  /// Red alert states (no user / error).
  bool get isCriticalAlert =>
      this == StudyPostureKind.noUser || this == StudyPostureKind.error;

  StudyPostureAlertLevel? get alertLevel {
    if (isCriticalAlert) return StudyPostureAlertLevel.critical;
    if (isWarningAlert) return StudyPostureAlertLevel.warning;
    return null;
  }
}

enum StudyPostureAlertLevel {
  warning,
  critical,
}
