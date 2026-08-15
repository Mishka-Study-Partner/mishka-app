import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

import 'package:mishka_app/core/preferences/app_preferences.dart';

import 'community_invite_link.dart';

/// Receives invite URIs (cold start + while running) and queues them until the
/// signed-in home shell can call [joinFromPending].
class CommunityInviteDeepLinkCoordinator extends ChangeNotifier {
  CommunityInviteDeepLinkCoordinator._();

  static final CommunityInviteDeepLinkCoordinator instance =
      CommunityInviteDeepLinkCoordinator._();

  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;
  CommunityInviteLink? _pending;
  bool _initialized = false;

  CommunityInviteLink? get pending => _pending;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    // Deep links disabled — restore app_links listener when re-enabled.
    return;

    // await _restoreFromPreferences();
    //
    // try {
    //   final initial = await _appLinks.getInitialLink();
    //   if (initial != null) {
    //     await _enqueueUri(initial);
    //   }
    // } catch (e) {
    //   if (kDebugMode) {
    //     debugPrint('Community invite initial link error: $e');
    //   }
    // }
    //
    // _subscription ??= _appLinks.uriLinkStream.listen(
    //   _enqueueUri,
    //   onError: (Object e) {
    //     if (kDebugMode) {
    //       debugPrint('Community invite link stream error: $e');
    //     }
    //   },
    // );
  }

  Future<void> disposeCoordinator() async {
    await _subscription?.cancel();
    _subscription = null;
    _initialized = false;
  }

  Future<void> _restoreFromPreferences() async {
    final raw = AppPreferences.pendingCommunityInviteJson;
    if (raw == null || raw.isEmpty) return;
    try {
      final link = CommunityInviteLink.fromJsonString(raw);
      if (!link.isEmpty) {
        _pending = link;
      }
    } catch (_) {
      await AppPreferences.clearPendingCommunityInviteLink();
    }
  }

  Future<void> _enqueueUri(Uri uri) async {
    final link = CommunityInviteLink.tryParse(uri);
    if (link == null || link.isEmpty) return;
    _pending = link;
    await AppPreferences.setPendingCommunityInviteLink(link.toJsonString());
    notifyListeners();
  }

  Future<void> clearPending() async {
    _pending = null;
    await AppPreferences.clearPendingCommunityInviteLink();
    notifyListeners();
  }

  Future<void> restorePending(CommunityInviteLink link) async {
    if (link.isEmpty) return;
    _pending = link;
    await AppPreferences.setPendingCommunityInviteLink(link.toJsonString());
    notifyListeners();
  }
}
