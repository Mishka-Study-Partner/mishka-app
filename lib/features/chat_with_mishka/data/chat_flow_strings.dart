import 'package:mishka_app/features/chat_with_mishka/data/controller/chat_flow_controller.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_response_helpers.dart';
import 'package:mishka_app/l10n/app_localizations.dart';

/// Localized copy + label matching for [ChatFlowController] (supports restored EN labels).
class ChatFlowStrings {
  ChatFlowStrings(this.l10n);

  final AppLocalizations l10n;

  String get greeting => l10n.chatGreeting;
  String get analyzingPdf => l10n.chatAnalyzingPdf;
  String get whichTool => l10n.chatWhichTool;
  String get waitForExplanation => l10n.chatWaitForExplanation;
  String get uploadPdfHint => l10n.chatUploadPdfHint;
  String get chooseDifficultyHint => l10n.chatChooseDifficultyHint;
  String get askMishkaHint => l10n.askMishka;

  String get difficultySimple => l10n.chatDifficultySimple;
  String get difficultyIntermediate => l10n.chatDifficultyIntermediate;
  String get difficultyAdvanced => l10n.chatDifficultyAdvanced;

  String get toolQuiz => l10n.chatToolQuiz;
  String get toolFlashcards => l10n.chatToolFlashcards;
  String get toolMindMap => l10n.chatToolMindMap;
  String get toolSummarize => l10n.chatToolSummarize;

  String get regenerate => l10n.chatRegenerate;
  String get anotherTool => l10n.chatAnotherTool;

  List<String> get difficultyOptions => [
        difficultySimple,
        difficultyIntermediate,
        difficultyAdvanced,
      ];

  List<String> get toolOptions => [
        toolQuiz,
        toolFlashcards,
        toolMindMap,
      ];

  List<String> get postToolOptions => [regenerate, anotherTool];

  String toolSelected(String label) => l10n.chatToolSelected(label);
  String regenerating(String toolName) => l10n.chatRegenerating(toolName);

  String toolName(StudyAction action) {
    return switch (action) {
      StudyAction.quiz => toolQuiz,
      StudyAction.flashcards => toolFlashcards,
      StudyAction.mindmap => toolMindMap,
      StudyAction.summarize => toolSummarize,
    };
  }

  String errorRegenerationFailed(Object error) => _aiOrGeneric(
        l10n.chatRegenerationFailed,
        error,
      );

  String errorAnalyzePdfFailed(Object error) => _aiOrGeneric(
        l10n.chatAnalyzePdfFailed,
        error,
      );

  String errorToolGenerationFailed(Object error) => _aiOrGeneric(
        l10n.chatToolGenerationFailed,
        error,
      );

  String errorChatFailed(Object error) => _aiOrGeneric(
        l10n.chatMessageFailed,
        error,
      );

  String errorSessionStartFailed(Object error) => _aiOrGeneric(
        l10n.chatSessionStartFailed,
        error,
      );

  String _aiOrGeneric(String Function(String error) template, Object error) {
    if (error is AiSessionNotFoundException ||
        error is ChatSessionNotFoundException) {
      return l10n.chatAiSessionExpired;
    }
    if (AiResponseHelpers.looksLikeConnectionFailure(error)) {
      return l10n.chatAiServerUnreachable;
    }
    if (error is AiServiceException ||
        AiResponseHelpers.looksLikeProviderError(error.toString())) {
      return l10n.chatAiServiceUnavailable;
    }
    return template(error.toString());
  }

  /// For explanation bubbles restored from history or returned before validation.
  String sanitizeExplanation(String text) =>
      AiResponseHelpers.displayText(text, l10n.chatAiServiceUnavailable);

  String get newChatTitle => l10n.chatNewChatTitle;
  String get newChatMessage => l10n.chatNewChatMessage;
  String get newChatConfirm => l10n.chatNewChatConfirm;

  bool isRegenerate(String value) =>
      value == regenerate || value == 'Regenerate';

  bool isAnotherTool(String value) =>
      value == anotherTool || value == 'Another Tool';

  DifficultyLevel? difficultyForLabel(String value) {
    if (value == difficultySimple || value == 'Simple') {
      return DifficultyLevel.simple;
    }
    if (value == difficultyIntermediate || value == 'Intermediate') {
      return DifficultyLevel.intermediate;
    }
    if (value == difficultyAdvanced ||
        value == 'Advanced' ||
        value == 'Hard') {
      return DifficultyLevel.advanced;
    }
    return null;
  }

  StudyAction? toolActionForLabel(String value) {
    if (value == toolQuiz || value == 'Quiz') return StudyAction.quiz;
    if (value == toolFlashcards || value == 'Flashcards') {
      return StudyAction.flashcards;
    }
    if (value == toolMindMap || value == 'Mind Map') {
      return StudyAction.mindmap;
    }
    if (value == toolSummarize || value == 'Summarize') {
      return StudyAction.summarize;
    }
    return null;
  }

  String localizeOptionLabel(String stored) {
    if (stored == 'Simple') return difficultySimple;
    if (stored == 'Intermediate') return difficultyIntermediate;
    if (stored == 'Advanced' || stored == 'Hard') return difficultyAdvanced;
    if (stored == 'Quiz') return toolQuiz;
    if (stored == 'Flashcards') return toolFlashcards;
    if (stored == 'Mind Map') return toolMindMap;
    if (stored == 'Summarize') return toolSummarize;
    if (stored == 'Regenerate') return regenerate;
    if (stored == 'Another Tool') return anotherTool;
    return stored;
  }
}
