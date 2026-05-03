class ExplanationResult {
  final String sessionId;
  final String explanation;
  final double confidenceScore;

  ExplanationResult({
    required this.sessionId,
    required this.explanation,
    required this.confidenceScore,
  });
}
