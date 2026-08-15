const quizProgressKey = 'quizProgress';

class QuizProgressSnapshot {
  const QuizProgressSnapshot({
    this.currentQuestionIndex = 0,
    this.selectedAnswers = const {},
    this.questionCorrect = const {},
    this.showResults = false,
    this.completed = false,
    this.percent,
  });

  final int currentQuestionIndex;
  final Map<int, int> selectedAnswers;
  final Map<int, bool> questionCorrect;
  final bool showResults;
  final bool completed;
  final int? percent;

  Map<String, dynamic> toJson() {
    return {
      'currentQuestionIndex': currentQuestionIndex,
      'selectedAnswers': selectedAnswers.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'questionCorrect': questionCorrect.map(
        (key, value) => MapEntry(key.toString(), value),
      ),
      'showResults': showResults,
      'completed': completed,
      if (percent != null) 'percent': percent,
    };
  }

  factory QuizProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return QuizProgressSnapshot(
      currentQuestionIndex: _readInt(json['currentQuestionIndex']) ?? 0,
      selectedAnswers: _readIntIntMap(json['selectedAnswers']),
      questionCorrect: _readIntBoolMap(json['questionCorrect']),
      showResults: json['showResults'] == true,
      completed: json['completed'] == true,
      percent: _readInt(json['percent']),
    );
  }
}

bool isQuizToolData(Map<String, dynamic> toolData) {
  final raw = (toolData['tool_type'] ?? '').toString().toLowerCase();
  return raw.contains('quiz') || toolData['questions'] is List;
}

QuizProgressSnapshot? readQuizProgress(Map<String, dynamic> toolData) {
  final raw = toolData[quizProgressKey];
  if (raw is! Map) return null;
  return QuizProgressSnapshot.fromJson(Map<String, dynamic>.from(raw));
}

Map<String, dynamic> applyQuizProgress({
  required Map<String, dynamic> toolData,
  required QuizProgressSnapshot progress,
}) {
  final data = Map<String, dynamic>.from(toolData);
  data[quizProgressKey] = progress.toJson();
  return data;
}

Map<String, dynamic> clearQuizProgress(Map<String, dynamic> toolData) {
  final data = Map<String, dynamic>.from(toolData);
  data.remove(quizProgressKey);
  return data;
}

int? _readInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

Map<int, int> _readIntIntMap(Object? raw) {
  if (raw is! Map) return const {};
  final out = <int, int>{};
  raw.forEach((key, value) {
    final index = int.tryParse(key.toString());
    final answer = _readInt(value);
    if (index != null && answer != null) {
      out[index] = answer;
    }
  });
  return out;
}

Map<int, bool> _readIntBoolMap(Object? raw) {
  if (raw is! Map) return const {};
  final out = <int, bool>{};
  raw.forEach((key, value) {
    final index = int.tryParse(key.toString());
    if (index != null) {
      out[index] = value == true;
    }
  });
  return out;
}
