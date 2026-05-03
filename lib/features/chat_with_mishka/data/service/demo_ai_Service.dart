import 'dart:math';

import '../controller/chat_flow_controller.dart';



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

class MishkaDemoService {
  final _rng = Random();

  /// Simulate "explain PDF" without any backend
  Future<ExplanationResult> explainPdf({
    required String pdfPath,
    required DifficultyLevel difficulty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final sid = "demo-${DateTime.now().millisecondsSinceEpoch}";
    final explanation = _buildExplanation(difficulty);

    // Confidence tends to be higher for "advanced" in our demo
    final base = switch (difficulty) {
      DifficultyLevel.simple => 0.82,
      DifficultyLevel.intermediate => 0.88,
      DifficultyLevel.advanced => 0.93,
    };
    final confidence = (base + (_rng.nextDouble() * 0.03)).clamp(0.0, 0.99);

    return ExplanationResult(
      sessionId: sid,
      explanation: explanation,
      confidenceScore: confidence.toDouble(),
    );
  }

  /// Generate tool payload as JSON map, based on difficulty
  Future<Map<String, dynamic>> generateTool({
    required String sessionId,
    required String action, // 'quiz' | 'flashcards' | 'mindmap'
    required DifficultyLevel difficulty,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));

    final confidence = switch (difficulty) {
      DifficultyLevel.simple => 0.84,
      DifficultyLevel.intermediate => 0.89,
      DifficultyLevel.advanced => 0.94,
    };

    if (action == "quiz") {
      return _quizJson(sessionId, difficulty, confidence);
    }
    if (action == "flashcards") {
      return _flashcardsJson(sessionId, difficulty, confidence);
    }
    if (action == "mindmap") {
      return _mindmapJson(sessionId, difficulty, confidence);
    }

    // if unknown:
    return {
      "tool_type": "unknown",
      "session_id": sessionId,
      "confidence_score": confidence,
      "data": {},
    };
  }

  // ---------------- Helpers ----------------

  String _buildExplanation(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.simple:
        return """
**Level: Simple**

This PDF explains key ideas in a very basic way:
- What business research is
- Why we use research design
- Main types of research (exploratory, descriptive, causal)
- How we collect data (surveys, interviews)

✅ Focus: easy definitions + quick bullets.
""";

      case DifficultyLevel.intermediate:
        return """
**Level: Intermediate**

This PDF covers research design with more details:
- Research problem → objectives → hypotheses
- Choosing the right design (exploratory / descriptive / causal)
- Data collection methods and when to use each
- Reliability & validity basics

✅ Focus: concepts + when/why + light examples.
""";

      case DifficultyLevel.advanced:
        return """
**Level: Advanced**

This PDF can be understood as a structured pipeline:
1) Define the research problem precisely (scope, variables, assumptions)
2) Select design type:
   - Exploratory (unknown problem)
   - Descriptive (measure/describe)
   - Causal (cause-effect testing)
3) Choose measurement + sampling strategy
4) Ensure quality: reliability, validity, bias reduction
5) Plan analysis: descriptive stats, hypothesis testing, model selection

✅ Focus: rigorous structure + decisions + quality control.
""";
    }
  }

  Map<String, dynamic> _quizJson(
      String sessionId,
      DifficultyLevel level,
      double confidence,
      ) {
    final questions = switch (level) {
      DifficultyLevel.simple => [
        {
          "q": "What is business research?",
          "options": [
            "A process to collect/analyze data for decisions",
            "Only writing reports",
            "Only marketing ads",
            "Guessing customer needs"
          ],
          "answer_index": 0,
        },
        {
          "q": "Which research type is used to explore an unclear problem?",
          "options": ["Causal", "Exploratory", "Descriptive", "Experimental"],
          "answer_index": 1,
        },
      ],
      DifficultyLevel.intermediate => [
        {
          "q": "Which design is best to measure market characteristics (age, income, usage)?",
          "options": ["Exploratory", "Descriptive", "Causal", "None"],
          "answer_index": 1,
        },
        {
          "q": "Reliability means:",
          "options": [
            "Consistency of measurement",
            "Truth of measurement",
            "Speed of data collection",
            "Lower cost"
          ],
          "answer_index": 0,
        },
        {
          "q": "Validity means:",
          "options": [
            "Consistent results always",
            "Measures what it should measure",
            "Only for experiments",
            "Only for surveys"
          ],
          "answer_index": 1,
        },
      ],
      DifficultyLevel.advanced => [
        {
          "q": "In causal research, the key goal is to:",
          "options": [
            "Describe characteristics",
            "Test cause-effect relations",
            "Explore ideas only",
            "Avoid hypotheses"
          ],
          "answer_index": 1,
        },
        {
          "q": "Which threatens internal validity the most?",
          "options": ["Randomization", "Confounding variables", "Controls", "Replication"],
          "answer_index": 1,
        },
        {
          "q": "A good sampling frame should be:",
          "options": [
            "Biased toward easy respondents",
            "Complete & representative of the population",
            "Only online users",
            "Only customers"
          ],
          "answer_index": 1,
        },
      ],
    };

    return {
      "tool_type": "quiz",
      "session_id": sessionId,
      "confidence_score": confidence,
      "data": {
        "difficulty": level.name,
        "questions": questions,
      },
    };
  }

  Map<String, dynamic> _flashcardsJson(
      String sessionId,
      DifficultyLevel level,
      double confidence,
      ) {
    final cards = switch (level) {
      DifficultyLevel.simple => [
        {"front": "Business Research", "back": "Collect & analyze data to make decisions."},
        {"front": "Exploratory Research", "back": "Used when the problem is unclear."},
        {"front": "Descriptive Research", "back": "Describes characteristics of a group/market."},
      ],
      DifficultyLevel.intermediate => [
        {"front": "Reliability", "back": "Consistency of measurement across time/items."},
        {"front": "Validity", "back": "Measures what it is supposed to measure."},
        {"front": "Causal Research", "back": "Tests cause-effect using experiments or models."},
      ],
      DifficultyLevel.advanced => [
        {"front": "Internal Validity", "back": "Confidence that X caused Y, not confounders."},
        {"front": "Sampling Frame", "back": "List/representation of population elements."},
        {"front": "Measurement Bias", "back": "Systematic error caused by instrument/process."},
      ],
    };

    return {
      "tool_type": "flashcards",
      "session_id": sessionId,
      "confidence_score": confidence,
      "data": {
        "difficulty": level.name,
        "cards": cards,
      },
    };
  }

  Map<String, dynamic> _mindmapJson(
      String sessionId,
      DifficultyLevel level,
      double confidence,
      ) {
    // Auto-drawn idea: nested nodes
    final nodes = switch (level) {
      DifficultyLevel.simple => [
        {
          "title": "Business Research",
          "children": [
            {"title": "Definition"},
            {
              "title": "Types",
              "children": [
                {"title": "Exploratory"},
                {"title": "Descriptive"},
                {"title": "Causal"},
              ],
            },
            {
              "title": "Data Collection",
              "children": [
                {"title": "Surveys"},
                {"title": "Interviews"},
              ],
            },
          ],
        }
      ],
      DifficultyLevel.intermediate => [
        {
          "title": "Research Design",
          "children": [
            {"title": "Problem & Objectives"},
            {
              "title": "Design Types",
              "children": [
                {"title": "Exploratory"},
                {"title": "Descriptive"},
                {"title": "Causal"},
              ],
            },
            {
              "title": "Quality",
              "children": [
                {"title": "Reliability"},
                {"title": "Validity"},
                {"title": "Bias"},
              ],
            },
            {
              "title": "Methods",
              "children": [
                {"title": "Survey"},
                {"title": "Interview"},
                {"title": "Observation"},
              ],
            },
          ],
        }
      ],
      DifficultyLevel.advanced => [
        {
          "title": "Business Research Pipeline",
          "children": [
            {
              "title": "1) Problem Formulation",
              "children": [
                {"title": "Scope"},
                {"title": "Variables"},
                {"title": "Assumptions"},
              ],
            },
            {
              "title": "2) Design Choice",
              "children": [
                {"title": "Exploratory → discovery"},
                {"title": "Descriptive → measurement"},
                {"title": "Causal → testing"},
              ],
            },
            {
              "title": "3) Sampling & Measurement",
              "children": [
                {"title": "Sampling frame"},
                {"title": "Bias control"},
                {"title": "Instrumentation"},
              ],
            },
            {
              "title": "4) Analysis Plan",
              "children": [
                {"title": "Descriptive stats"},
                {"title": "Hypothesis testing"},
                {"title": "Model selection"},
              ],
            },
            {
              "title": "5) Validity & Reliability",
              "children": [
                {"title": "Internal validity"},
                {"title": "External validity"},
                {"title": "Reliability checks"},
              ],
            },
          ],
        }
      ],
    };

    return {
      "tool_type": "mindmap",
      "session_id": sessionId,
      "confidence_score": confidence,
      "data": {
        "difficulty": level.name,
        "nodes": nodes,
      },
    };
  }
}
