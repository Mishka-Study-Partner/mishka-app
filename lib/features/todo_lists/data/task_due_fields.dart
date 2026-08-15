import 'package:intl/intl.dart';

/// Task due fields as stored by Prisma/backend:
/// - [dueDate]: calendar date at UTC midnight (`2026-06-02T00:00:00.000Z`)
/// - [dueTime]: UTC clock time on epoch date (`1970-01-01T05:15:00.000Z`)
abstract final class TaskDueFields {
  /// Encodes a local wall-clock pick into split UTC date + epoch time carrier.
  static Map<String, String> encode(DateTime local) {
    final l = local.isUtc ? local.toLocal() : local;
    final utc = l.toUtc();
    return {
      'dueDate': DateTime.utc(utc.year, utc.month, utc.day).toIso8601String(),
      'dueTime': DateTime.utc(
        1970,
        1,
        1,
        utc.hour,
        utc.minute,
        utc.second,
      ).toIso8601String(),
    };
  }

  static DateTime? decode({
    dynamic dueDate,
    dynamic dueTime,
  }) {
    if (dueDate == null) return null;

    final dateStr = dueDate.toString().trim();
    if (dateStr.isEmpty) return null;

    final parsedDate = DateTime.tryParse(dateStr);
    final timeStr = dueTime?.toString().trim() ?? '';

    if (timeStr.isNotEmpty) {
      final parsedTime = DateTime.tryParse(timeStr);
      if (parsedTime != null) {
        final timeUtc = parsedTime.toUtc();
        if (_isEpochTimeCarrier(timeUtc)) {
          if (parsedDate == null) return null;
          final dateUtc = parsedDate.toUtc();
          return DateTime.utc(
            dateUtc.year,
            dateUtc.month,
            dateUtc.day,
            timeUtc.hour,
            timeUtc.minute,
            timeUtc.second,
          ).toLocal();
        }
        return parsedTime.toLocal();
      }

      late int year;
      late int month;
      late int day;
      if (parsedDate != null) {
        final utc = parsedDate.toUtc();
        year = utc.year;
        month = utc.month;
        day = utc.day;
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateStr)) {
        final parts = dateStr.split('-');
        year = int.parse(parts[0]);
        month = int.parse(parts[1]);
        day = int.parse(parts[2]);
      } else {
        return null;
      }

      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final second = parts.length >= 3
            ? int.tryParse(parts[2].split('.').first) ?? 0
            : 0;
        return DateTime.utc(year, month, day, hour, minute, second).toLocal();
      }
    }

    if (parsedDate == null) return null;

    if (_isUtcDateOnlyMidnight(parsedDate)) {
      final utc = parsedDate.toUtc();
      return DateTime(utc.year, utc.month, utc.day);
    }

    return parsedDate.toLocal();
  }

  static bool hasDueTime({dynamic dueTime, dynamic dueDate}) {
    final timeStr = dueTime?.toString().trim() ?? '';
    if (timeStr.isNotEmpty) {
      final parsedTime = DateTime.tryParse(timeStr);
      if (parsedTime != null) {
        if (_isEpochTimeCarrier(parsedTime.toUtc())) return true;
        return !_isUtcDateOnlyMidnight(parsedTime);
      }
      return true;
    }

    final parsed = DateTime.tryParse(dueDate?.toString() ?? '');
    if (parsed == null) return false;
    return !_isUtcDateOnlyMidnight(parsed);
  }

  static bool _isEpochTimeCarrier(DateTime utc) {
    return utc.year == 1970 && utc.month == 1 && utc.day == 1;
  }

  static bool _isUtcDateOnlyMidnight(DateTime parsed) {
    final utc = parsed.toUtc();
    return utc.hour == 0 &&
        utc.minute == 0 &&
        utc.second == 0 &&
        utc.millisecond == 0;
  }

  static String formatDate(DateTime? deadline, String locale) {
    if (deadline == null) return '--';
    return DateFormat.yMMMd(locale).format(deadline);
  }

  static String formatTime({
    required DateTime? deadline,
    required bool hasDueTime,
    required String locale,
    String empty = '--',
  }) {
    if (deadline == null || !hasDueTime) return empty;
    return DateFormat.jm(locale).format(deadline);
  }
}
