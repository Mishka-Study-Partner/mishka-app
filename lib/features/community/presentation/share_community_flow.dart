import 'package:flutter/material.dart';
import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/community/data/community_share_remote_data_source.dart';
import 'package:mishka_app/features/community/data/models/joined_community_models.dart';
import 'package:mishka_app/features/community/presentation/widgets/share_to_community_sheet.dart';
import 'package:mishka_app/features/community/presentation/widgets/share_to_community_success_dialog.dart';
import 'package:mishka_app/features/our_community/utils/community_share_navigation.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Loads joined communities and opens the share picker sheet.
Future<ShareCommunitySelection?> pickCommunityGroupsForShare(
  BuildContext context, {
  CommunityShareRemoteDataSource? dataSource,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final source = dataSource ?? CommunityShareRemoteDataSource(ApiService());

  try {
    final communities = await source.getJoinedCommunitiesForShare();
    if (!context.mounted) return null;
    if (communities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noCommunityChannelsFound)),
      );
      return null;
    }

    return showShareToCommunitySheet(
      context: context,
      communities: communities,
    );
  } catch (e) {
    if (!context.mounted) return null;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.failedToLoadChannels(e.toString()))),
    );
    return null;
  }
}

/// Shows the post-share success popup from the design.
Future<void> showShareCompletedFeedback({
  required BuildContext context,
  required ShareCommunitySelection selection,
  VoidCallback? onOpenGroup,
}) async {
  if (!context.mounted) return;

  final action = await showShareToCommunitySuccessDialog(
    context: context,
  );
  if (!context.mounted || action == null) return;

  if (action == ShareToCommunitySuccessAction.openGroup) {
    if (onOpenGroup != null) {
      onOpenGroup();
      return;
    }
    await openCommunityGroupChatFromSelection(
      context,
      selection: selection,
    );
  }
}
