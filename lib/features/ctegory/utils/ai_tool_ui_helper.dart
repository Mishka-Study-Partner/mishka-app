import 'package:mishka_app/features/chat_with_mishka/presentation/screens/direct_tool_generator_screen.dart';
import 'package:mishka_app/features/ctegory/data/models/ai_tool_api_model.dart';
import 'package:mishka_app/features/home/presentation/widgets/ai_tool_card.dart';
import 'package:mishka_app/generated/assets.dart';

/// Shared mapping for AI tool cards (home grid + category AI tools screen).
class AiToolUiHelper {
  AiToolUiHelper._();

  static String imageForTitle(String text) {
    final t = text.toLowerCase();
    if (t.contains('flash')) return Assets.imagesHomeFlashcardsCard;
    if (t.contains('quiz')) return Assets.imagesHomeSumaryQuizzesCard;
    if (t.contains('summary') || t.contains('summar')) {
      return Assets.imagesHomeSumaryQuizzesCard;
    }
    if (t.contains('mind')) return Assets.imagesHomeChatCard;
    if (t.contains('chat')) return Assets.imagesHomeChatCard;
    return Assets.imagesHomeChatCard;
  }

  static DirectToolKind? directKindForTitle(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('flash')) return DirectToolKind.flashcards;
    if (lower.contains('quiz')) return DirectToolKind.quiz;
    if (lower.contains('mind')) return DirectToolKind.mindmap;
    if (lower.contains('summ')) return DirectToolKind.summarize;
    return null;
  }

  static CardCornerPosition cornerForIndex(int index) {
    return switch (index % 4) {
      0 => CardCornerPosition.topLeft,
      1 => CardCornerPosition.topRight,
      2 => CardCornerPosition.bottomLeft,
      _ => CardCornerPosition.bottomRight,
    };
  }

  /// Static fallback cards when `GET /ai-tools` returns empty.
  static List<AiToolApiModel> fallbackTools({
    required String chatTitle,
    required String summarizeTitle,
    required String flashcardsTitle,
    required String quizzesTitle,
  }) {
    return [
      AiToolApiModel(id: 'fallback-chat', title: chatTitle),
      AiToolApiModel(id: 'fallback-summarize', title: summarizeTitle),
      AiToolApiModel(id: 'fallback-flashcards', title: flashcardsTitle),
      AiToolApiModel(id: 'fallback-quizzes', title: quizzesTitle),
    ];
  }
}
