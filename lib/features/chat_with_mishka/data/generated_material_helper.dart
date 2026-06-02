import 'package:flutter/material.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/community/presentation/share_community_flow.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

SavedMaterialType savedTypeForToolData(Map<String, dynamic> toolData) {
  final raw = (toolData['tool_type'] ?? '').toString().toLowerCase();
  if (raw.contains('flash')) return SavedMaterialType.flashcards;
  if (raw.contains('quiz')) return SavedMaterialType.quiz;
  if (raw.contains('mind')) return SavedMaterialType.mindmap;
  if (raw.contains('summ')) return SavedMaterialType.summary;
  return SavedMaterialType.quiz;
}

class GeneratedMaterialHelper {
  GeneratedMaterialHelper(this.context, this._savedLibrary);

  final BuildContext context;
  final SavedLibraryRemoteDataSource _savedLibrary;

  Future<void> shareTool({
    required Map<String, dynamic> toolData,
    String? savedLibraryId,
    String? sharedEntityId,
    required void Function(String entityId) onEntityId,
    VoidCallback? onOpenGroup,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await pickCommunityGroupsForShare(context);
    if (selection == null || selection.groups.isEmpty) return;

    try {
      final type = savedTypeForToolData(toolData);
      var entityId = sharedEntityId;
      if (entityId == null || entityId.isEmpty) {
        entityId = await _savedLibrary.ensureGeneratedMaterialEntity(
          type: type,
          toolData: toolData,
        );
        onEntityId(entityId);
      }

      final channelIds = selection.channelIds;
      if (savedLibraryId != null && savedLibraryId.isNotEmpty) {
        await _savedLibrary.shareSavedMaterialToChannels(
          type: type,
          savedRowId: savedLibraryId,
          channelIds: channelIds,
        );
      } else {
        await _savedLibrary.shareGeneratedMaterialToChannels(
          type: type,
          entityId: entityId,
          channelIds: channelIds,
        );
      }

      if (!context.mounted) return;
      await showShareCompletedFeedback(
        context: context,
        selection: selection,
        onOpenGroup: onOpenGroup,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.shareFailed(e.toString()))),
      );
    }
  }

  Future<String?> saveTool(Map<String, dynamic> toolData) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final ref = await _savedLibrary.saveGeneratedMaterial(
        type: savedTypeForToolData(toolData),
        toolData: toolData,
      );
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedToYourLibrary)),
      );
      return ref.savedId;
    } catch (e) {
      if (!context.mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.saveFailed(e.toString()))),
      );
      return null;
    }
  }
}
