import 'package:flutter/material.dart';
import 'package:mishka_app/core/network/api_exception.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';
import 'package:mishka_app/features/community/presentation/share_community_flow.dart';
import 'package:mishka_app/features/our_community/data/community_channel_material_publisher.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';
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
      final normalized = normalizeToolData(toolData);
      final type = savedTypeForToolData(normalized);
      var entityId = sharedEntityId;
      if (entityId == null || entityId.isEmpty) {
        entityId = await _savedLibrary.ensureGeneratedMaterialEntity(
          type: type,
          toolData: normalized,
        );
        onEntityId(entityId);
      }

      final channelIds = selection.channelIds;
      final targets = selection.groups
          .map(
            (group) => (
              communityId: group.communityId,
              channelId: group.id,
            ),
          )
          .toList();

      final shareNote = selection.note;

      if (savedLibraryId != null && savedLibraryId.isNotEmpty) {
        await _savedLibrary.shareSavedMaterialToChannels(
          type: type,
          savedRowId: savedLibraryId,
          channelIds: channelIds,
          note: shareNote,
        );
        final kind = switch (type) {
          SavedMaterialType.flashcards => SavedContentKind.flashcards,
          SavedMaterialType.quiz => SavedContentKind.quiz,
          SavedMaterialType.summary => SavedContentKind.summary,
          SavedMaterialType.mindmap => SavedContentKind.mindmap,
        };
        await ensureSavedRowMaterialPosted(
          repository: SavedRepository(),
          kind: kind,
          savedListRowId: savedLibraryId,
          note: shareNote,
          targets: targets,
        );
      } else {
        await _savedLibrary.shareGeneratedMaterialToChannels(
          type: type,
          entityId: entityId,
          channelIds: channelIds,
          note: shareNote,
        );
        await ensureEntityMaterialPosted(
          type: type,
          entityId: entityId,
          note: shareNote,
          targets: targets,
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
      _showFloatingSnack(_errorMessage(e, l10n.shareFailed));
    }
  }

  Future<SavedMaterialRef?> saveTool(Map<String, dynamic> toolData) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final normalized = normalizeToolData(toolData);
      final type = savedTypeForToolData(normalized);
      final ref = await _savedLibrary.saveGeneratedMaterial(
        type: type,
        toolData: normalized,
      );
      if (!context.mounted) return null;
      _showFloatingSnack(l10n.savedToYourLibrary);
      return ref;
    } catch (e) {
      if (!context.mounted) return null;
      _showFloatingSnack(_errorMessage(e, l10n.saveFailed));
      return null;
    }
  }

  String _errorMessage(Object error, String Function(String) localize) {
    if (error is ApiException) {
      return localize(_apiExceptionMessage(error));
    }
    if (error is FormatException) {
      return localize(error.message);
    }
    return localize(error.toString());
  }

  String _apiExceptionMessage(ApiException error) {
    final details = error.details;
    if (details is List && details.isNotEmpty) {
      final parts = details.whereType<Map>().map((row) {
        final path = row['path']?.toString();
        final message = row['message']?.toString();
        if (path != null && path.isNotEmpty) return '$path: $message';
        return message ?? row.toString();
      }).where((part) => part.trim().isNotEmpty);
      if (parts.isNotEmpty) {
        return parts.join('; ');
      }
    }
    return error.userMessage;
  }

  void _showFloatingSnack(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Pridi'),
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        ),
      );
    });
  }
}
