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
}

enum MessageType {
  system,
  text,
  explanation,
  file,
  options,
  selection,
  toolPreview, // for displaying quiz/flashcards inline in chat
}

class ChatMessage {
  final bool isFromMishka;
  final MessageType type;
  final DateTime time;

  final String? text;                 // for system/explanation
  final String? fileName;             // for file
  final List<String>? options;         // for options bubble (difficulty/actions)
  final String? selectedOption;        // for selection bubble (Option B)
  final Map<String, dynamic>? toolData; // for toolPreview (quiz/flashcards)

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
  ChatStep step = ChatStep.idle;

  String? uploadedPdfName;
  DifficultyLevel? difficulty;
  String? sessionId;
  StudyAction? lastSelectedTool; // Track last tool for regenerate

  final List<ChatMessage> messages = [];

  // =========================
  // PROPERTIES
  // =========================
  bool get isTypingEnabled => step == ChatStep.freeInteraction;

  // =========================
  // INITIALIZATION
  // =========================
  ChatFlowController() {
    // Add initial greeting
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.text,
        text: "Hello, please upload your material to start our journey",
        time: DateTime.now(),
      ),
    );
  }

  // =========================
  // PDF UPLOAD
  // =========================
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
        options: ["Simple", "Intermediate", "Advanced"],
        time: DateTime.now(),
      ),
    );
  }

  // =========================
  // DIFFICULTY
  // =========================
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
        text: "Analyzing PDF...",
        time: DateTime.now(),
      ),
    );
  }

  // =========================
  // EXPLANATION READY
  // =========================
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
        options: ["Quiz", "Flashcards", "Mind Map"],
        time: DateTime.now(),
      ),
    );
  }

  // =========================
  // TOOL SELECT
  // =========================
  StudyAction onActionSelected(String label) {
    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.selection,
        selectedOption: label,
        time: DateTime.now(),
      ),
    );

    // Show what was chosen
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.text,
        text: "Great! You selected: $label. Generating it for you...",
        time: DateTime.now(),
      ),
    );

    StudyAction action;
    switch (label) {
      case "Quiz":
        action = StudyAction.quiz;
        break;
      case "Flashcards":
        action = StudyAction.flashcards;
        break;
      case "Mind Map":
        action = StudyAction.mindmap;
        break;
      default:
        action = StudyAction.quiz;
    }
    
    lastSelectedTool = action; // Store for regenerate
    return action;
  }

  // =========================
  // TOOL GENERATED - SHOW OPTIONS
  // =========================
  void onToolGenerated(StudyAction toolType) {
    lastSelectedTool = toolType;
    
    // Add options for regenerate or another tool
    messages.add(
      ChatMessage(
        isFromMishka: true,
        type: MessageType.options,
        options: ["Regenerate", "Another Tool"],
        time: DateTime.now(),
      ),
    );
  }

  // =========================
  // REGENERATE OR ANOTHER TOOL
  // =========================
  StudyAction? onRegenerateOrAnotherTool(String choice) {
    messages.add(
      ChatMessage(
        isFromMishka: false,
        type: MessageType.selection,
        selectedOption: choice,
        time: DateTime.now(),
      ),
    );

    if (choice == "Regenerate") {
      if (lastSelectedTool != null) {
        messages.add(
          ChatMessage(
            isFromMishka: true,
            type: MessageType.text,
            text: "Regenerating ${_toolName(lastSelectedTool!)}...",
            time: DateTime.now(),
          ),
        );
        return lastSelectedTool;
      }
    } else if (choice == "Another Tool") {
      // Show tool options again
      messages.add(
        ChatMessage(
          isFromMishka: true,
          type: MessageType.text,
          text: "Which tool would you like to use?",
          time: DateTime.now(),
        ),
      );
      messages.add(
        ChatMessage(
          isFromMishka: true,
          type: MessageType.options,
          options: ["Quiz", "Flashcards", "Mind Map"],
          time: DateTime.now(),
        ),
      );
    }
    return null;
  }

  String _toolName(StudyAction action) {
    switch (action) {
      case StudyAction.quiz:
        return "Quiz";
      case StudyAction.flashcards:
        return "Flashcards";
      case StudyAction.mindmap:
        return "Mind Map";
    }
  }

  // =========================
  // CHAT MESSAGES
  // =========================
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

  // =========================
  // HELPERS
  // =========================
  String _difficultyLabel(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.simple:
        return "Simple";
      case DifficultyLevel.intermediate:
        return "Intermediate";
      case DifficultyLevel.advanced:
        return "Advanced";
    }
  }
}
