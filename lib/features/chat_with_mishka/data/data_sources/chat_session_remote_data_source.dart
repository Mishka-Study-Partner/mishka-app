import 'package:mishka_app/core/network/api_endpoints.dart';
import 'package:mishka_app/core/network/api_service.dart';

class ChatSessionModel {
  const ChatSessionModel({
    required this.id,
    required this.title,
    this.startedAt,
    this.isActive = true,
    this.uploadOriginalFilename,
  });

  final String id;
  final String title;
  final String? startedAt;
  final bool isActive;
  final String? uploadOriginalFilename;

  factory ChatSessionModel.fromJson(Map<String, dynamic> json) {
    return ChatSessionModel(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? 'Chat').toString(),
      startedAt: json['startedAt']?.toString(),
      isActive: json['isActive'] as bool? ?? true,
      uploadOriginalFilename: json['uploadOriginalFilename']?.toString(),
    );
  }
}

class ChatTimelineMessage {
  const ChatTimelineMessage({
    required this.id,
    required this.senderType,
    required this.messageContent,
    required this.inputType,
    this.createdAt,
  });

  final String id;
  final String senderType;
  final String messageContent;
  final String inputType;
  final String? createdAt;

  factory ChatTimelineMessage.fromJson(Map<String, dynamic> json) {
    return ChatTimelineMessage(
      id: (json['id'] ?? '').toString(),
      senderType: (json['senderType'] ?? '').toString(),
      messageContent: (json['messageContent'] ?? '').toString(),
      inputType: (json['inputType'] ?? 'text').toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class ChatSessionTimeline {
  const ChatSessionTimeline({
    required this.session,
    this.messages = const [],
  });

  final ChatSessionModel session;
  final List<ChatTimelineMessage> messages;

  factory ChatSessionTimeline.fromJson(Object? raw) {
    if (raw is! Map) {
      return ChatSessionTimeline(
        session: ChatSessionModel(id: '', title: 'Chat'),
      );
    }
    final map = Map<String, dynamic>.from(raw);
    final sessionRaw = map['session'];
    final session = sessionRaw is Map
        ? ChatSessionModel.fromJson(Map<String, dynamic>.from(sessionRaw))
        : ChatSessionModel(id: (map['id'] ?? '').toString(), title: 'Chat');
    final messagesRaw = (map['messages'] as List?) ?? const [];
    final messages = messagesRaw
        .whereType<Map>()
        .map((e) => ChatTimelineMessage.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return ChatSessionTimeline(session: session, messages: messages);
  }
}

class ChatSessionRemoteDataSource {
  ChatSessionRemoteDataSource(this._api);

  final ApiService _api;

  Future<List<ChatSessionModel>> listSessions() async {
    final env = await _api.get<List<ChatSessionModel>>(
      ApiEndpoints.chatSessions,
      dataFromJson: (raw) {
        final list = (raw as List?) ?? const [];
        return list
            .whereType<Map>()
            .map((e) => ChatSessionModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
    );
    return env.data ?? const [];
  }

  Future<ChatSessionModel> createSession({
    required String title,
    String? uploadOriginalFilename,
  }) async {
    final env = await _api.post<ChatSessionModel>(
      ApiEndpoints.chatSessions,
      data: {
        'title': title,
        'startedAt': DateTime.now().toUtc().toIso8601String(),
        if (uploadOriginalFilename != null &&
            uploadOriginalFilename.isNotEmpty)
          'uploadOriginalFilename': uploadOriginalFilename,
      },
      dataFromJson: (raw) {
        if (raw is Map) {
          return ChatSessionModel.fromJson(Map<String, dynamic>.from(raw));
        }
        throw const FormatException('Invalid chat session response');
      },
    );
    final data = env.data;
    if (data == null || data.id.isEmpty) {
      throw const FormatException('Empty chat session response');
    }
    return data;
  }

  Future<ChatSessionTimeline> getTimeline(String sessionId) async {
    final env = await _api.get<ChatSessionTimeline>(
      ApiEndpoints.chatSessionTimeline(sessionId),
      dataFromJson: (raw) => ChatSessionTimeline.fromJson(raw),
    );
    return env.data ??
        ChatSessionTimeline(
          session: ChatSessionModel(id: sessionId, title: 'Chat'),
        );
  }

  Future<void> createMessage({
    required String sessionId,
    required String senderType,
    required String messageContent,
    String inputType = 'text',
  }) async {
    await _api.post<void>(
      ApiEndpoints.chatMessages,
      data: {
        'sessionId': sessionId,
        'senderType': senderType,
        'messageContent': messageContent,
        if (inputType.isNotEmpty) 'inputType': inputType,
      },
    );
  }
}
