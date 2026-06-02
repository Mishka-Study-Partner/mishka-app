import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/core/network/api_service.dart';

import 'timer_model.dart';

class StudyRemoteDataSource {
  StudyRemoteDataSource(this._api);
  final ApiService _api;

  /// Fetches the catalog: concentration presets + call-with-Mishka modes.
  Future<StudyCatalog> getCatalog() async {
    final env = await _api.get<StudyCatalog>(
      ApiEndpoints.studyWithMishkaCatalog,
      dataFromJson: (raw) {
        if (raw is Map) {
          return StudyCatalog.fromJson(Map<String, dynamic>.from(raw));
        }
        return const StudyCatalog();
      },
    );
    return env.data ?? const StudyCatalog();
  }

  /// Fetches saved custom timer presets.
  Future<List<CustomTimerPreset>> getCustomTimers() async {
    final env = await _api.get<List<CustomTimerPreset>>(
      ApiEndpoints.studyWithMishkaCustomTimers,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => CustomTimerPreset.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  /// Creates a custom timer preset on the backend.
  Future<CustomTimerPreset?> createCustomTimer({
    required int studyMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    String? label,
  }) async {
    final env = await _api.post<CustomTimerPreset?>(
      ApiEndpoints.studyWithMishkaCustomTimers,
      data: {
        'focusMinutes': studyMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        if (label != null) 'name': label,
      },
      dataFromJson: (raw) {
        if (raw is Map) {
          return CustomTimerPreset.fromJson(Map<String, dynamic>.from(raw));
        }
        return null;
      },
    );
    return env.data;
  }

  /// Deletes a custom timer preset.
  Future<void> deleteCustomTimer(String id) async {
    await _api.delete<void>(ApiEndpoints.studyWithMishkaCustomTimerById(id));
  }

  /// Starts a backend session. Returns the session ID or null on failure.
  Future<String?> startSession({
    required String topLevelMode,
    String? concentrationPreset,
    String? customPresetId,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) async {
    try {
      return await _postStartSession(
        topLevelMode: topLevelMode,
        concentrationPreset: concentrationPreset,
        customPresetId: customPresetId,
        focusMinutes: focusMinutes,
        shortBreakMinutes: shortBreakMinutes,
        longBreakMinutes: longBreakMinutes,
      );
    } on ApiException catch (e) {
      if (kDebugMode) {
        debugPrint(
          '📚 StudySession start failed: ${e.statusCode} ${e.error} ${e.message}',
        );
      }
      // Active session blocks a new start — end stuck sessions and retry once.
      if (e.statusCode == 400 && _isActiveSessionConflict(e)) {
        await _abandonActiveSessions();
        try {
          return await _postStartSession(
            topLevelMode: topLevelMode,
            concentrationPreset: concentrationPreset,
            customPresetId: customPresetId,
            focusMinutes: focusMinutes,
            shortBreakMinutes: shortBreakMinutes,
            longBreakMinutes: longBreakMinutes,
          );
        } on ApiException catch (retryError) {
          if (kDebugMode) {
            debugPrint(
              '📚 StudySession start retry failed: ${retryError.message}',
            );
          }
        }
      }
      return null;
    } catch (e) {
      if (kDebugMode) debugPrint('📚 StudySession start error: $e');
      return null;
    }
  }

  Future<String?> _postStartSession({
    required String topLevelMode,
    String? concentrationPreset,
    String? customPresetId,
    int? focusMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
  }) async {
    final data = <String, dynamic>{
      'topLevelMode': topLevelMode,
      if (concentrationPreset != null) 'concentrationPreset': concentrationPreset,
      if (customPresetId != null && customPresetId.isNotEmpty)
        'customPresetId': customPresetId,
      'platform': Platform.isIOS ? 'ios' : 'android',
    };
    if (concentrationPreset == 'custom' &&
        (customPresetId == null || customPresetId.isEmpty) &&
        focusMinutes != null) {
      data['customOverrides'] = {
        'focusMinutes': focusMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
      };
    }
    final env = await _api.post<String?>(
      ApiEndpoints.studyWithMishkaSessionStart,
      data: data,
      dataFromJson: (raw) {
        if (raw is Map) {
          final id = raw['id'] ?? raw['sessionId'];
          if (id != null && id.toString().isNotEmpty) return id.toString();
        }
        return null;
      },
    );
    final id = env.data;
    if (kDebugMode && id != null) {
      debugPrint('📚 StudySession started: $id');
    }
    return id;
  }

  bool _isActiveSessionConflict(ApiException e) {
    final msg = e.message.toLowerCase();
    return msg.contains('current session') ||
        msg.contains('active') && msg.contains('session');
  }

  Future<void> _abandonActiveSessions() async {
    final env = await _api.get<List<dynamic>>(
      ApiEndpoints.studyWithMishkaSessions,
      dataFromJson: (raw) => (raw as List?) ?? const [],
    );
    final sessions = env.data ?? const [];
    for (final item in sessions) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final status = (map['status'] ?? '').toString().toLowerCase();
      if (status != 'active' && status != 'paused') continue;
      final id = (map['id'] ?? map['sessionId'] ?? '').toString();
      if (id.isEmpty) continue;
      await endSession(id, outcome: 'abandoned');
    }
  }

  /// Ends a backend session.
  Future<void> endSession(String sessionId, {String outcome = 'completed'}) async {
    try {
      await _api.post<void>(
        ApiEndpoints.studyWithMishkaSessionEnd(sessionId),
        data: {'outcome': outcome},
      );
    } catch (_) {}
  }

  /// Submits a check-in response for the active session.
  Future<void> submitCheckIn({
    required String sessionId,
    required String kind,
    bool? responseBool,
    int? responseInt,
  }) async {
    try {
      await _api.post<void>(
        ApiEndpoints.studyWithMishkaSessionCheckIns(sessionId),
        data: {
          'kind': kind,
          if (responseBool != null) 'responseBool': responseBool,
          if (responseInt != null) 'responseInt': responseInt,
        },
      );
    } catch (_) {}
  }

  /// Notify backend of timer pause.
  Future<void> pauseSession(String sessionId) async {
    try {
      await _api.post<void>(ApiEndpoints.studyWithMishkaSessionPause(sessionId));
    } catch (_) {}
  }

  /// Notify backend of timer resume.
  Future<void> resumeSession(String sessionId) async {
    try {
      await _api.post<void>(ApiEndpoints.studyWithMishkaSessionResume(sessionId));
    } catch (_) {}
  }

  /// Notify backend of phase transition.
  Future<void> advancePhase(String sessionId, {required String nextPhase}) async {
    try {
      await _api.post<void>(
        ApiEndpoints.studyWithMishkaSessionAdvancePhase(sessionId),
        data: {'nextPhase': nextPhase},
      );
    } catch (_) {}
  }

  /// Start a call break (call_with_mishka mode only).
  Future<void> startCallBreak(String sessionId) async {
    try {
      await _api.post<void>(
        ApiEndpoints.studyWithMishkaCallBreakStart(sessionId),
      );
    } catch (_) {}
  }

  /// End a call break.
  Future<void> endCallBreak(String sessionId, {int? durationSeconds}) async {
    try {
      await _api.post<void>(
        ApiEndpoints.studyWithMishkaCallBreakEnd(sessionId),
        data: {
          if (durationSeconds != null) 'durationSeconds': durationSeconds,
        },
      );
    } catch (_) {}
  }
}

/// Parsed catalog from GET /study-with-mishka/catalog
class StudyCatalog {
  final List<ConcentrationPreset> concentrationPresets;
  final List<CallWithMishkaMode> callModes;

  const StudyCatalog({
    this.concentrationPresets = const [],
    this.callModes = const [],
  });

  factory StudyCatalog.fromJson(Map<String, dynamic> json) {
    final presets = <ConcentrationPreset>[];

    final presetKeys = [
      'concentrationModes', 'concentrationPresets', 'concentration_presets',
      'concentration_modes', 'presets', 'modes', 'timers',
    ];
    List? rawPresets;
    for (final key in presetKeys) {
      if (json[key] is List) {
        rawPresets = json[key] as List;
        break;
      }
    }

    if (rawPresets == null) {
      for (final entry in json.entries) {
        if (entry.value is List && (entry.value as List).isNotEmpty) {
          final first = (entry.value as List).first;
          if (first is Map && (first.containsKey('defaults') || first.containsKey('studyMinutes'))) {
            rawPresets = entry.value as List;
            break;
          }
        }
      }
    }

    if (rawPresets != null) {
      for (final item in rawPresets) {
        if (item is Map) {
          presets.add(ConcentrationPreset.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }

    final modes = <CallWithMishkaMode>[];
    final modeKeys = [
      'callWithMishkaModes', 'call_with_mishka_modes', 'callModes',
      'call_modes', 'callWithMishka',
    ];
    for (final key in modeKeys) {
      final val = json[key];
      if (val is List) {
        for (final item in val) {
          if (item is Map) {
            modes.add(CallWithMishkaMode.fromJson(Map<String, dynamic>.from(item)));
          }
        }
        break;
      } else if (val is Map) {
        modes.add(CallWithMishkaMode.fromJson(Map<String, dynamic>.from(val)));
        break;
      }
    }

    return StudyCatalog(concentrationPresets: presets, callModes: modes);
  }
}

class ConcentrationPreset {
  final String id;
  final String label;
  final String? tagline;
  final String? description;
  final String? structureSummary;
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int? totalCycles;

  bool get isCustom => id == 'custom_timer' || id == 'custom';

  const ConcentrationPreset({
    required this.id,
    required this.label,
    this.tagline,
    this.description,
    this.structureSummary,
    required this.studyMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    this.totalCycles,
  });

  StudyTimerModel toTimerModel() => StudyTimerModel(
        label,
        studyMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        modeId: id,
      );

  factory ConcentrationPreset.fromJson(Map<String, dynamic> json) {
    final name = (json['name'] ?? json['label'] ?? json['title'] ?? '').toString();

    // Timer values may be at top level or nested under "defaults"
    final defaults = json['defaults'] is Map
        ? Map<String, dynamic>.from(json['defaults'] as Map)
        : <String, dynamic>{};

    int focus = _parseInt(
      json['studyMinutes'] ?? json['study_minutes'] ?? json['focusMinutes'] ?? json['focus_minutes'] ??
      defaults['focusMinutes'] ?? defaults['focus_minutes'] ?? defaults['focusMin'] ??
      defaults['studyMinutes'] ?? defaults['study_minutes'] ?? defaults['study'] ?? defaults['focus'] ?? 0,
    );
    int shortBreak = _parseInt(
      json['shortBreakMinutes'] ?? json['short_break_minutes'] ?? json['shortBreak'] ??
      defaults['shortBreakMinutes'] ?? defaults['short_break_minutes'] ?? defaults['shortBreak'] ?? defaults['shortBreakMin'] ?? 0,
    );
    int longBreak = _parseInt(
      json['longBreakMinutes'] ?? json['long_break_minutes'] ?? json['longBreak'] ??
      defaults['longBreakMinutes'] ?? defaults['long_break_minutes'] ?? defaults['longBreak'] ?? defaults['longBreakMin'] ?? 0,
    );
    int? cycles;
    final rawCycles = json['totalCycles'] ?? json['pomodoros'] ?? json['cycles'] ??
        json['pomodorosBeforeLongBreak'] ??
        defaults['pomodorosBeforeLongBreak'] ?? defaults['pomodoros'] ??
        defaults['totalCycles'] ?? defaults['cycles'];
    if (rawCycles != null) cycles = _parseInt(rawCycles);

    return ConcentrationPreset(
      id: (json['id'] ?? json['key'] ?? '').toString(),
      label: name,
      tagline: json['tagline']?.toString(),
      description: json['description']?.toString(),
      structureSummary: json['structureSummary']?.toString() ?? json['structure_summary']?.toString(),
      studyMinutes: focus,
      shortBreakMinutes: shortBreak,
      longBreakMinutes: longBreak,
      totalCycles: cycles,
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class CallWithMishkaMode {
  final String id;
  final String label;
  final String? description;
  final bool cameraOn;

  const CallWithMishkaMode({
    required this.id,
    required this.label,
    this.description,
    this.cameraOn = false,
  });

  factory CallWithMishkaMode.fromJson(Map<String, dynamic> json) {
    return CallWithMishkaMode(
      id: (json['id'] ?? json['key'] ?? '').toString(),
      label: (json['label'] ?? json['name'] ?? json['title'] ?? '').toString(),
      description: json['description']?.toString(),
      cameraOn: json['cameraOn'] as bool? ?? json['camera_on'] as bool? ?? false,
    );
  }
}

class CustomTimerPreset {
  final String id;
  final int studyMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final String? label;
  final DateTime? createdAt;

  const CustomTimerPreset({
    required this.id,
    required this.studyMinutes,
    required this.shortBreakMinutes,
    required this.longBreakMinutes,
    this.label,
    this.createdAt,
  });

  StudyTimerModel toTimerModel() => StudyTimerModel(
        label ?? 'Custom',
        studyMinutes,
        shortBreakMinutes,
        longBreakMinutes,
        modeId: 'custom',
        customPresetId: id.isNotEmpty ? id : null,
      );

  factory CustomTimerPreset.fromJson(Map<String, dynamic> json) {
    return CustomTimerPreset(
      id: (json['id'] ?? '').toString(),
      studyMinutes: ConcentrationPreset._parseInt(json['focusMinutes'] ?? json['focus_minutes'] ?? json['studyMinutes'] ?? json['study_minutes'] ?? json['study']),
      shortBreakMinutes: ConcentrationPreset._parseInt(json['shortBreakMinutes'] ?? json['short_break_minutes'] ?? json['shortBreak']),
      longBreakMinutes: ConcentrationPreset._parseInt(json['longBreakMinutes'] ?? json['long_break_minutes'] ?? json['longBreak']),
      label: json['label']?.toString() ?? json['name']?.toString(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
    );
  }
}
