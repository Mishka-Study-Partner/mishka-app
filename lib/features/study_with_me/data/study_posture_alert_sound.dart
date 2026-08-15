import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mishka_app/core/preferences/app_preferences.dart';

import 'study_monitor_response.dart';

/// Soft alert tones for ML posture warnings (orange) and critical states (red).
abstract final class StudyPostureAlertSound {
  static AudioPlayer? _player;
  static bool _contextConfigured = false;
  static bool _nativePlayerUnavailable = false;

  static const _warningAsset = 'sounds/posture_warning.wav';
  static const _criticalAsset = 'sounds/posture_critical.wav';
  static const _repeatGap = Duration(milliseconds: 140);

  static int _playSession = 0;

  static int _repeatCount(StudyPostureAlertLevel level) => switch (level) {
        StudyPostureAlertLevel.warning => 2,
        StudyPostureAlertLevel.critical => 5,
      };

  static Future<void> play(StudyPostureAlertLevel level) async {
    if (!AppPreferences.notificationsEnabled) return;

    final repeats = _repeatCount(level);
    final session = ++_playSession;

    if (_nativePlayerUnavailable) {
      unawaited(_playSystemFallback(level, repeats, session));
      return;
    }

    final asset = switch (level) {
      StudyPostureAlertLevel.warning => _warningAsset,
      StudyPostureAlertLevel.critical => _criticalAsset,
    };

    try {
      await _configureAudioContext();
      final player = _player ??= AudioPlayer()..setReleaseMode(ReleaseMode.stop);
      await player.stop();
      await _playAssetRepeated(
        player: player,
        asset: asset,
        repeats: repeats,
        session: session,
      );
    } on MissingPluginException catch (e) {
      _nativePlayerUnavailable = true;
      if (kDebugMode) {
        debugPrint(
          'StudyPostureAlertSound: native player unavailable ($e). '
          'Stop the app and run `flutter run` once.',
        );
      }
      unawaited(_playSystemFallback(level, repeats, session));
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('StudyPostureAlertSound: $e\n$st');
      }
      unawaited(_playSystemFallback(level, repeats, session));
    }
  }

  static Future<void> _playAssetRepeated({
    required AudioPlayer player,
    required String asset,
    required int repeats,
    required int session,
  }) async {
    for (var i = 0; i < repeats; i++) {
      if (session != _playSession) return;
      await player.play(AssetSource(asset), volume: 0.75);
      await player.onPlayerComplete.first;
      if (i < repeats - 1 && session == _playSession) {
        await Future<void>.delayed(_repeatGap);
      }
    }
  }

  /// Mixes with the camera preview on iOS/Android (valid audioplayers config).
  static Future<void> _configureAudioContext() async {
    if (_contextConfigured) return;
    await AudioPlayer.global.setAudioContext(
      AudioContext(
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playAndRecord,
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.defaultToSpeaker,
          },
        ),
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.assistanceSonification,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
      ),
    );
    _contextConfigured = true;
  }

  static Future<void> _playSystemFallback(
    StudyPostureAlertLevel level,
    int repeats,
    int session,
  ) async {
    for (var i = 0; i < repeats; i++) {
      if (session != _playSession) return;
      SystemSound.play(SystemSoundType.click);
      switch (level) {
        case StudyPostureAlertLevel.warning:
          HapticFeedback.lightImpact();
        case StudyPostureAlertLevel.critical:
          HapticFeedback.heavyImpact();
      }
      if (i < repeats - 1 && session == _playSession) {
        await Future<void>.delayed(_repeatGap);
      }
    }
  }

  static Future<void> dispose() async {
    _playSession++;
    await _player?.dispose();
    _player = null;
    _contextConfigured = false;
  }
}
