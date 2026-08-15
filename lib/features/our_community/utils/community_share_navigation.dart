import 'package:flutter/material.dart';

import 'package:mishka_app/features/community/data/models/joined_community_models.dart';
import 'package:mishka_app/features/our_community/data/community_json_helpers.dart';
import 'package:mishka_app/features/our_community/data/community_models.dart';
import 'package:mishka_app/features/our_community/data/community_repository.dart';
import 'package:mishka_app/features/our_community/presentation/screens/community_group_chat_screen.dart';

CommunityGroupModel communityGroupModelFromShare(CommunityGroup group) {
  return CommunityGroupModel(
    id: group.id,
    name: group.name,
    memberLabel: memberCountLabel(group.memberCount),
    imageUrl: group.imageUrl,
    icon: iconForGroupName(group.name),
    iconColor: colorForGroupName(group.name),
    joined: group.joined,
  );
}

/// Opens the first selected group chat after a successful share.
Future<void> openCommunityGroupChatFromSelection(
  BuildContext context, {
  required ShareCommunitySelection selection,
  CommunityRepository? repository,
}) async {
  final group = selection.primaryGroup;
  if (group == null || !context.mounted) return;

  final repo = repository ?? CommunityRepository();
  try {
    final community = await repo.refreshCommunity(group.communityId);
    if (!context.mounted) return;
    if (community == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Community not found')),
      );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => CommunityGroupChatScreen(
          community: community,
          group: communityGroupModelFromShare(group),
          repository: repo,
        ),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}
