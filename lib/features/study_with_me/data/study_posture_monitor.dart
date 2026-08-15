import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'camera_frame_encoder.dart';
import 'ml_service_config.dart';
import 'study_monitor_response.dart';

/// WebSocket client for Mishka Vision ML (`/ws/study-session`).
///
/// Uses [CameraController.startImageStream] (not [CameraController.takePicture])
/// so the preview does not flash on each frame.
class StudyPostureMonitor extends ChangeNotifier {
  StudyPostureMonitor({Uri? webSocketUri})
      : _wsUri = webSocketUri ?? MlServiceConfig.webSocketUri;

  final Uri _wsUri;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  CameraController? _camera;
  bool _streamStarted = false;

  bool _connecting = false;
  bool _connected = false;
  bool _encodeInFlight = false;
  DateTime? _lastFrameSentAt;
  StudyMonitorResponse? _lastResponse;
  StudyPostureKind _postureKind = StudyPostureKind.unknown;
  String? _lastError;

  final Map<String, int> _statusCounts = {};
  int _sampleCount = 0;
  DateTime? _connectedAt;
  bool _disposed = false;

  bool get isConnected => _connected;
  bool get isConnecting => _connecting;
  String? get lastRawStatus => _lastResponse?.status;
  String? get lastError => _lastError;
  StudyPostureKind get postureKind => _postureKind;
  Color? get indicatorColor => _lastResponse?.indicatorColor;
  int get sampleCount => _sampleCount;

  Map<String, int> get statusCounts => Map.unmodifiable(_statusCounts);

  Map<String, dynamic> buildMlReportPayload() {
    final connectedSeconds = _connectedAt == null
        ? 0
        : DateTime.now().difference(_connectedAt!).inSeconds;
    return {
      'schemaVersion': 2,
      'source': 'study_monitor_ws',
      'modelBaseUrl': MlServiceConfig.baseUrl,
      'summary': {
        'sampleCount': _sampleCount,
        'connectedSeconds': connectedSeconds,
        'statusCounts': Map<String, int>.from(_statusCounts),
        'lastStatus': _lastResponse?.status,
        'lastPostureKind': _postureKind.name,
        if (_lastResponse?.colorBgr != null)
          'lastColorBgr': _lastResponse!.colorBgr,
      },
    };
  }

  Future<void> start(CameraController camera) async {
    if (_disposed) return;
    await _cleanup();
    _camera = camera;
    _resetStats();
    _postureKind = StudyPostureKind.unknown;
    _connecting = true;
    _notifyIfActive();

    try {
      final socket = await WebSocket.connect(
        _wsUri.toString(),
        headers: MlServiceConfig.connectionHeaders,
      );
      _channel = IOWebSocketChannel(socket);
      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
      _connected = true;
      _connectedAt = DateTime.now();
      _connecting = false;
      _lastError = null;
      if (kDebugMode) {
        debugPrint('📷 StudyMonitor WS connected: $_wsUri');
      }
      await _startImageStream(camera);
    } catch (e) {
      _connecting = false;
      _connected = false;
      _lastError = e.toString();
      _postureKind = StudyPostureKind.unknown;
      if (kDebugMode) {
        debugPrint('📷 StudyMonitor WS connect failed: $e');
      }
    }
    _notifyIfActive();
  }

  Future<void> _startImageStream(CameraController camera) async {
    if (!camera.value.isInitialized || camera.value.isStreamingImages) {
      return;
    }
    await camera.startImageStream(_onCameraFrame);
    _streamStarted = true;
  }

  Future<void> _stopImageStream() async {
    final camera = _camera;
    if (camera == null || !_streamStarted) return;
    if (camera.value.isStreamingImages) {
      try {
        await camera.stopImageStream();
      } catch (_) {}
    }
    _streamStarted = false;
  }

  Future<void> stop() async {
    await _cleanup();
    _notifyIfActive();
  }

  Future<void> _cleanup() async {
    await _stopImageStream();
    await _subscription?.cancel();
    _subscription = null;
    try {
      await _channel?.sink.close();
    } catch (_) {}
    _channel = null;
    _camera = null;
    _connected = false;
    _connecting = false;
    _encodeInFlight = false;
    _lastFrameSentAt = null;
  }

  void _notifyIfActive() {
    if (!_disposed) notifyListeners();
  }

  void _resetStats() {
    _statusCounts.clear();
    _sampleCount = 0;
    _lastResponse = null;
    _connectedAt = null;
  }

  void _onCameraFrame(CameraImage image) {
    if (!_connected || _encodeInFlight) return;
    final channel = _channel;
    if (channel == null) return;

    final now = DateTime.now();
    final lastSent = _lastFrameSentAt;
    if (lastSent != null &&
        now.difference(lastSent) < MlServiceConfig.frameInterval) {
      return;
    }

    _encodeInFlight = true;
    _lastFrameSentAt = now;
    unawaited(_encodeAndSend(image, channel));
  }

  Future<void> _encodeAndSend(CameraImage image, WebSocketChannel channel) async {
    try {
      final bytes = CameraFrameEncoder.toJpeg(image);
      if (!_connected || bytes == null || bytes.isEmpty) return;
      channel.sink.add(bytes);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📷 StudyMonitor frame send failed: $e');
      }
    } finally {
      _encodeInFlight = false;
    }
  }

  void _onMessage(dynamic message) {
    if (message is! String) return;
    try {
      final decoded = jsonDecode(message);
      if (decoded is! Map) return;
      final response = StudyMonitorResponse.fromJson(
        Map<String, dynamic>.from(decoded),
      );
      if (response.status.isEmpty) return;
      _applyResponse(response);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('📷 StudyMonitor bad JSON: $message ($e)');
      }
    }
  }

  void _applyResponse(StudyMonitorResponse response) {
    final previousStatus = _lastResponse?.status;
    _lastResponse = response;
    _sampleCount++;
    final key = response.status.toUpperCase();
    _statusCounts[key] = (_statusCounts[key] ?? 0) + 1;
    final nextKind = response.kind;
    final changed =
        previousStatus != response.status || _postureKind != nextKind;
    _postureKind = nextKind;
    if (changed) _notifyIfActive();
  }

  void _onError(Object error) {
    _lastError = error.toString();
    _connected = false;
    _postureKind = StudyPostureKind.unknown;
    if (kDebugMode) {
      debugPrint('📷 StudyMonitor WS error: $error');
    }
    _notifyIfActive();
  }

  void _onDone() {
    _connected = false;
    _postureKind = StudyPostureKind.unknown;
    if (kDebugMode) {
      debugPrint('📷 StudyMonitor WS closed');
    }
    _notifyIfActive();
  }

  /// Lightweight WebSocket handshake to verify the ML service is reachable.
  static Future<bool> checkAvailability({
    Uri? webSocketUri,
    Duration timeout = const Duration(seconds: 5),
  }) async {
    WebSocket? socket;
    try {
      final uri = webSocketUri ?? MlServiceConfig.webSocketUri;
      socket = await WebSocket.connect(
        uri.toString(),
        headers: MlServiceConfig.connectionHeaders,
      ).timeout(timeout);
      return true;
    } catch (_) {
      return false;
    } finally {
      try {
        await socket?.close();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_cleanup());
    super.dispose();
  }
}
