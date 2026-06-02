import 'dart:convert';

import 'package:mishka_app/features/chat_with_mishka/data/chat_flow_strings.dart';
import 'package:mishka_app/features/chat_with_mishka/data/data_sources/chat_session_remote_data_source.dart';

enum ChatStep {
  idle,
  pdfUploaded,
  waitingForDifficulty,
  explaining,
  freeInteraction,
}

enum DifficultyLevel {
  simple,
  intermediate,
  advanced,
}

enum StudyAction {
  quiz,
  flashcards,
  mindmap,
  summarize,
}

enum MessageType {
  system,
  text,
  explanation,
  file,
  options,
  selection,
  toolPreview,
}

class ChatMessage {
  final bool isFromMishka;
  final MessageType type;
  final DateTime time;

  final String? text;
  final String? fileName;
  final List<String>? options;
  final String? selectedOption;
  final Map<String, dynamic>? toolData;

  const ChatMessage({
    required this.isFromMishka,
    required this.type,
    required this.time,
    this.text,
    this.fileName,
    this.options,
    this.selectedOption,
    this.toolData,
  });
}

class ChatFlowController {
  ChatFlowController({
    ChatFlowStrings? strings,
    bool withGreeting = true,
  })  : _strings = strings {
    if (withGreeting) {
      _addGreeting();
    }
  }

  ChatFlowStrings? _strings;

  ChatStep step = ChatStep.idle;

  String? uploadedPdfName;
  DifficultyLevel? difficulty;
  String? sessionId;
  StudyAction? lastSelectedTool;

  final List<ChatMessage> messages = [];

  bool get isTypingEnabled => step == ChatStep.freeInteraction;

  void updateStrings(ChatFlowStrings strings) {
    _strings = strings;
  }

  void reset({bool withGreeting = true}) {
    messages.clear();
    uploadedPdfName = null;
    difficulty = null;
    sessionId = null;
    lastSelectedTool = null;
    step = ChatStep.idle;
    if (withGreeting) {
      _addGreeting();
    }
  }

  void _addGreeting() {
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.text,
        text: _strings?.greeting ??
            'Hello, please upload your material to start our journey',
        time: DateTime.now(),
      ),
    );
  }

  void restoreFromTimeline(ChatSessionTimeline timeline, String? aiSessionId) {
    messages.clear();

    if (aiSessionId != null && aiSessionId.isNotEmpty) {
      sessionId = aiSessionId;
    }

    uploadedPdfName = timeline.session.uploadOriginalFilename;

    for (final msg in timeline.messages) {
      if (msg.inputType == 'session_meta') {
        try {
          final meta =
              jsonDecode(msg.messageContent) as Map<String, dynamic>;
          final diff = meta['difficulty']?.toString();
          if (diff != null) {
            difficulty = _parseDifficultyName(diff);
          }
          final fromMeta = meta['aiSessionId']?.toString();
          if (fromMeta != null && fromMeta.isNotEmpty) {
            sessionId = fromMeta;
          }
        } catch (_) {}
        continue;
      }

      final restored = _messageFromTimeline(msg);
      if (restored != null) {
        messages.add(restored);
      }
    }

    if (sessionId != null) {
      step = ChatStep.freeInteraction;
    } else if (uploadedPdfName != null && uploadedPdfName!.isNotEmpty) {
      step = ChatStep.waitingForDifficulty;
    } else {
      step = ChatStep.idle;
    }

    if (messages.isEmpty) {
      _addGreeting();
    }
  }

  ChatMessage? _messageFromTimeline(ChatTimelineMessage msg) {
    final isFromMishka = msg.senderType != 'user';
    final time = DateTime.tryParse(msg.createdAt ?? '') ?? DateTime.now();

    switch (msg.inputType) {
      case 'explanation':
        return ChatMessage(
          isFromMishka: true,
          type: MessageType.explanation,
          text: msg.messageContent,
          time: time,
        );
      case 'file':
        return ChatMessage(
          isFromMishka: false,
          type: MessageType.file,
          fileName: msg.messageContent,
          time: time,
        );
      case 'options':
        try {
          final list = (jsonDecode(msg.messageContent) as List)
              .map((e) => e.toString())
              .toList();
          return ChatMessage(
            isFromMishka: true,
            type: MessageType.options,
            options: list,
            time: time,
          );
        } catch (_) {
          return null;
        }
      case 'selection':
        return ChatMessage(
          isFromMishka: false,
          type: MessageType.selection,
          selectedOption: msg.messageContent,
          time: time,
        );
      case 'tool_preview':
        try {
          final data = Map<String, dynamic>.from(
            jsonDecode(msg.messageContent) as Map,
          );
          return ChatMessage(
            isFromMishka: true,
            type: MessageType.toolPreview,
            toolData: data,
            time: time,
          );
        } catch (_) {
          return null;
        }
      case 'system':
        return ChatMessage(
          isFromMishka: true,
          type: MessageType.system,
          text: msg.messageContent,
          time: time,
        );
      default:
        return ChatMessage(
          isFromMishka: isFromMishka,
          type: MessageType.text,
          text: msg.messageContent,
          time: time,
        );
    }
  }

  DifficultyLevel? _parseDifficultyName(String raw) {
    return _strings?.difficultyForLabel(raw) ??
        switch (raw.toLowerCase()) {
          'simple' => DifficultyLevel.simple,
          'advanced' || 'hard' => DifficultyLevel.advanced,
          'intermediate' => DifficultyLevel.intermediate,
          _ => null,
        };
  }

  void onPdfUploaded({required String fileName}) {
    uploadedPdfName = fileName;
    step = ChatStep.waitingForDifficulty;

    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.file,
        fileName: fileName,
        time: DateTime.now(),
      ),
    );

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.options,
        options: _strings?.difficultyOptions ??
            const ['Simple', 'Intermediate', 'Advanced'],
        time: DateTime.now(),
      ),
    );
  }

  void onDifficultySelected(DifficultyLevel level) {
    difficulty = level;
    step = ChatStep.explaining;

    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.selection,
        selectedOption: _difficultyLabel(level),
        time: DateTime.now(),
      ),
    );

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.system,
        text: _strings?.analyzingPdf ?? 'Analyzing PDF...',
        time: DateTime.now(),
      ),
    );
  }

  void onExplanationReady({
    required String explanationText,
    required String sessionId,
  }) {
    this.sessionId = sessionId;
    step = ChatStep.freeInteraction;

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.explanation,
        text: explanationText,
        time: DateTime.now(),
      ),
    );

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.options,
        options: _strings?.toolOptions ??
            const ['Quiz', 'Flashcards', 'Mind Map', 'Summarize'],
        time: DateTime.now(),
      ),
    );
  }

  StudyAction onActionSelected(String label) {
    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.selection,
        selectedOption: label,
        time: DateTime.now(),
      ),
    );

    final action =
        _strings?.toolActionForLabel(label) ?? _legacyToolAction(label);

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.text,
        text: _strings?.toolSelected(label) ??
            'Great! You selected: $label. Generating it for you...',
        time: DateTime.now(),
      ),
    );

    lastSelectedTool = action;
    return action;
  }

  void onToolGenerated(StudyAction toolType) {
    lastSelectedTool = toolType;

    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.options,
        options: _strings?.postToolOptions ?? const ['Regenerate', 'Another Tool'],
        time: DateTime.now(),
      ),
    );
  }

  StudyAction? onRegenerateOrAnotherTool(String choice) {
    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.selection,
        selectedOption: choice,
        time: DateTime.now(),
      ),
    );

    final isRegenerate = _strings?.isRegenerate(choice) ?? choice == 'Regenerate';
    final isAnother = _strings?.isAnotherTool(choice) ?? choice == 'Another Tool';

    if (isRegenerate) {
      if (lastSelectedTool != null) {
        messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.text,
            text: _strings?.regenerating(_toolName(lastSelectedTool!)) ??
                'Regenerating ${_toolName(lastSelectedTool!)}...',
            time: DateTime.now(),
          ),
        );
        return lastSelectedTool;
      }
    } else if (isAnother) {
      messages.add(
        ChatMessage(
          isFromMishka: true,
          type: MessageType.text,
          text: _strings?.whichTool ?? 'Which tool would you like to use?',
          time: DateTime.now(),
        ),
      );
      messages.add(
        ChatMessage(
          isFromMishka: true,
          type: MessageType.options,
          options: _strings?.toolOptions ??
              const ['Quiz', 'Flashcards', 'Mind Map', 'Summarize'],
          time: DateTime.now(),
        ),
      );
    }
    return null;
  }

  String _toolName(StudyAction action) {
    if (_strings != null) return _strings!.toolName(action);
    return switch (action) {
      StudyAction.quiz => 'Quiz',
      StudyAction.flashcards => 'Flashcards',
      StudyAction.mindmap => 'Mind Map',
      StudyAction.summarize => 'Summarize',
    };
  }

  StudyAction _legacyToolAction(String label) {
    return switch (label) {
      'Flashcards' => StudyAction.flashcards,
      'Mind Map' => StudyAction.mindmap,
      'Summarize' => StudyAction.summarize,
      _ => StudyAction.quiz,
    };
  }

  void onUserChatMessage(String text) {
    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.text,
        text: text,
        time: DateTime.now(),
      ),
    );
  }

  void onMishkaChatReply(String reply) {
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.text,
        text: reply,
        time: DateTime.now(),
      ),
    );
  }

  void onToolPreviewGenerated({
    required Map<String, dynamic> toolData,
  }) {
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.toolPreview,
        toolData: toolData,
        time: DateTime.now(),
      ),
    );
  }

  String _difficultyLabel(DifficultyLevel level) {
    if (_strings != null) {
      return switch (level) {
        DifficultyLevel.simple => _strings!.difficultySimple,
        DifficultyLevel.intermediate => _strings!.difficultyIntermediate,
        DifficultyLevel.advanced => _strings!.difficultyAdvanced,
      };
    }
    return switch (level) {
      DifficultyLevel.simple => 'Simple',
      DifficultyLevel.intermediate => 'Intermediate',
      DifficultyLevel.advanced => 'Advanced',
    };
  }
}
