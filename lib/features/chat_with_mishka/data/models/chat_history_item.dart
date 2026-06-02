enum ChatHistoryKind { chat, quiz, flashcards, summary, mindmap }

class ChatHistoryItem {
  const ChatHistoryItem({
    required this.id,
    required this.label,
    required this.kind,
    this.chatSessionId,
    this.sortKey = '',
  });

  final String id;
  final String label;
  final ChatHistoryKind kind;
  /// Backend chat session to restore when this history row is opened.
  final String? chatSessionId;
  final String sortKey;

  bool get opensChatSession =>
      chatSessionId != null && chatSessionId!.isNotEmpty;
}

class ChatHistoryData {
  const ChatHistoryData({
    this.chats = const [],
    this.quizzes = const [],
    this.flashcards = const [],
    this.summaries = const [],
    this.mindmaps = const [],
  });

  final List<ChatHistoryItem> chats;
  final List<ChatHistoryItem> quizzes;
  final List<ChatHistoryItem> flashcards;
  final List<ChatHistoryItem> summaries;
  final List<ChatHistoryItem> mindmaps;

  bool get isEmpty =>
      chats.isEmpty &&
      quizzes.isEmpty &&
      flashcards.isEmpty &&
      summaries.isEmpty &&
      mindmaps.isEmpty;
}
