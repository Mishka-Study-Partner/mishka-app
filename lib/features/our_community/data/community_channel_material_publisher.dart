import 'dart:convert';

import 'package:mishka_app/core/network/api_service.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/saved_library_remote_data_source.dart';
import 'package:mishka_app/features/our_community/data/community_models.dart';
import 'package:mishka_app/features/our_community/data/community_remote_data_source.dart';
import 'package:mishka_app/features/saved/data/repositories/saved_repository.dart';
import 'package:mishka_app/features/saved/domain/saved_content_kind.dart';

typedef ChannelShareTarget = ({String communityId, String channelId});

/// Posts `inputType: material` channel messages when share API skips or omits them.
class CommunityChannelMaterialPublisher {
  CommunityChannelMaterialPublisher({CommunityRemoteDataSource? remote})
      : _remote = remote ?? CommunityRemoteDataSource(ApiService());

  final CommunityRemoteDataSource _remote;

  static String apiMaterialType(SavedMaterialType type) {
    return switch (type) {
      SavedMaterialType.quiz => 'quiz',
      SavedMaterialType.flashcards => 'flashcard_set',
      SavedMaterialType.summary => 'summary',
      SavedMaterialType.mindmap => 'mind_map',
    };
  }

  static SavedMaterialType materialTypeForKind(SavedContentKind kind) {
    return switch (kind) {
      SavedContentKind.flashcards => SavedMaterialType.flashcards,
      SavedContentKind.quiz => SavedMaterialType.quiz,
      SavedContentKind.summary => SavedMaterialType.summary,
      SavedContentKind.mindmap => SavedMaterialType.mindmap,
    };
  }

  /// Ensures a visible material bubble exists in the group chat.
  Future<void> ensureMaterialVisible({
    required String communityId,
    required String channelId,
    required String apiMaterialType,
    required String materialId,
    List<CommunityChatMessage>? knownMessages,
    String? note,
  }) async {
    if (materialId.isEmpty) return;

    final messages =
        knownMessages ?? await _remote.fetchMessages(communityId, channelId);

    final alreadyVisible = messages.any((message) {
      final ref = message.materialRef;
      if (ref == null) return false;
      return ref.materialId == materialId &&
          ref.materialType.toLowerCase() == apiMaterialType.toLowerCase();
    });
    if (alreadyVisible) return;

    final payload = <String, dynamic>{
      'materialType': apiMaterialType,
      'materialId': materialId,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    };

    await _remote.postMessage(
      communityId,
      channelId,
      messageContent: jsonEncode(payload),
      inputType: 'material',
    );
  }
}

Future<void> ensureSavedRowMaterialPosted({
  CommunityRemoteDataSource? remote,
  required SavedRepository repository,
  required SavedContentKind kind,
  required String savedListRowId,
  required List<ChannelShareTarget> targets,
  String? note,
  String? entityIdOverride,
  List<CommunityChatMessage>? knownMessages,
}) async {
  if (targets.isEmpty) return;

  final entityId = (entityIdOverride != null && entityIdOverride.isNotEmpty)
      ? entityIdOverride
      : await repository.tutorEntityIdForSavedRow(kind, savedListRowId);
  if (entityId == null || entityId.isEmpty) return;

  final publisher = CommunityChannelMaterialPublisher(remote: remote);
  final apiType = CommunityChannelMaterialPublisher.apiMaterialType(
    CommunityChannelMaterialPublisher.materialTypeForKind(kind),
  );

  for (final target in targets) {
    await publisher.ensureMaterialVisible(
      communityId: target.communityId,
      channelId: target.channelId,
      apiMaterialType: apiType,
      materialId: entityId,
      note: note,
      knownMessages: targets.length == 1 ? knownMessages : null,
    );
  }
}

Future<void> ensureEntityMaterialPosted({
  CommunityRemoteDataSource? remote,
  required SavedMaterialType type,
  required String entityId,
  required List<ChannelShareTarget> targets,
  String? note,
}) async {
  if (entityId.isEmpty || targets.isEmpty) return;

  final publisher = CommunityChannelMaterialPublisher(remote: remote);
  final apiType = CommunityChannelMaterialPublisher.apiMaterialType(type);

  for (final target in targets) {
    await publisher.ensureMaterialVisible(
      communityId: target.communityId,
      channelId: target.channelId,
      apiMaterialType: apiType,
      materialId: entityId,
      note: note,
    );
  }
}
