import 'package:mishka_app/core/preferences/app_preferences.dart';

import 'community_models.dart';

/// Persists saved (pinned) community ids when the API omits `isPinned` on memberships.
abstract final class CommunityPinnedStore {
  static final Set<String> _ids = {};
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;
    await AppPreferences.init();
    _ids
      ..clear()
      ..addAll(AppPreferences.pinnedCommunityIds);
    _loaded = true;
  }

  static bool isPinned(String communityId) =>
      communityId.isNotEmpty && _ids.contains(communityId);

  static Future<void> pin(String communityId) async {
    if (communityId.isEmpty) return;
    await ensureLoaded();
    if (!_ids.add(communityId)) return;
    await AppPreferences.setPinnedCommunityIds(_ids);
  }

  static Future<void> unpin(String communityId) async {
    if (communityId.isEmpty) return;
    await ensureLoaded();
    if (!_ids.remove(communityId)) return;
    await AppPreferences.setPinnedCommunityIds(_ids);
  }

  /// When the backend returns pinned flags, mirror them into local storage.
  static Future<void> reconcileWithMemberships(
    Iterable<CommunityModel> communities,
  ) async {
    await ensureLoaded();
    var changed = false;
    final memberIds = <String>{};
    for (final community in communities) {
      if (!community.isMember || community.id.isEmpty) continue;
      memberIds.add(community.id);
      if (community.isPinned) {
        if (_ids.add(community.id)) changed = true;
      } else if (_ids.remove(community.id)) {
        changed = true;
      }
    }
    final stale = _ids.where((id) => !memberIds.contains(id)).toList();
    for (final id in stale) {
      _ids.remove(id);
      changed = true;
    }
    if (changed) await AppPreferences.setPinnedCommunityIds(_ids);
  }
}
