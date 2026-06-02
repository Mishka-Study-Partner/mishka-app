import 'package:flutter/material.dart';

import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/features/community/presentation/share_community_flow.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/data/saved_detail_cache.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
import 'package:mishka_app/features/saved/presentation/widgets/saved_remove_confirm_dialog.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

Future<void> shareSavedLibraryItem({
  required BuildContext context,
  required SavedRepository repository,
  required SavedContentKind kind,
  required String savedListItemId,
  VoidCallback? onOpenGroup,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (savedListItemId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${l10n.errorPrefix}: ${l10n.savedDetailMissingListId}'),
      ),
    );
    return;
  }

  try {
    final selection = await pickCommunityGroupsForShare(context);
    if (selection == null || selection.groups.isEmpty) return;

    await repository.shareSavedLibraryRow(
      kind: kind,
      savedListRowId: savedListItemId,
      channelIds: selection.channelIds,
    );
    if (!context.mounted) return;
    await showShareCompletedFeedback(
      context: context,
      selection: selection,
      onOpenGroup: onOpenGroup,
    );
  } catch (e) {
    if (!context.mounted) return;
    final message = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.errorPrefix}: $message')),
    );
  }
}

/// Returns `true` when the row was deleted (caller may refresh or pop).
Future<bool> confirmAndDeleteSavedLibraryItem({
  required BuildContext context,
  required SavedRepository repository,
  required SavedContentKind kind,
  required String savedListItemId,
}) async {
  final l10n = AppLocalizations.of(context)!;
  if (savedListItemId.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('${l10n.errorPrefix}: ${l10n.savedDetailMissingListId}'),
      ),
    );
    return false;
  }

  final ok = await showSavedRemoveConfirmDialog(context);
  if (ok != true) return false;

  try {
    await repository.deleteSavedLibraryRow(kind, savedListItemId);
    await SavedDetailCache.clear(kind, savedListItemId);
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.savedLibraryRemoved)),
    );
    return true;
  } catch (e) {
    if (!context.mounted) return false;
    final message = e is ApiException ? e.message : e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${l10n.errorPrefix}: $message')),
    );
    return false;
  }
}
