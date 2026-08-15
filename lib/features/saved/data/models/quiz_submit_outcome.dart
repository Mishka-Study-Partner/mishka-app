class QuizSubmitOutcome {
  const QuizSubmitOutcome({
    required this.percent,
    this.attemptId,
  });

  final int percent;
  final String? attemptId;
}
