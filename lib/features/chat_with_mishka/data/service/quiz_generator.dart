class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

class QuizGenerator {
  static List<QuizQuestion> generateFromText(String text) {
    final sentences = text
        .split('.')
        .map((e) => e.trim())
        .where((e) => e.length > 20)
        .toList();

    final questions = <QuizQuestion>[];

    for (int i = 0; i < sentences.length && questions.length < 5; i++) {
      final sentence = sentences[i];

      questions.add(
        QuizQuestion(
          question: "What best describes the following?\n$sentence",
          options: [
            sentence,
            "Unrelated concept",
            "Incorrect definition",
            "None of the above",
          ],
          correctIndex: 0,
        ),
      );
    }

    return questions;
  }
}
