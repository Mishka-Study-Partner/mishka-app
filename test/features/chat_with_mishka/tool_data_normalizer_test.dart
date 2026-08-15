import 'package:flutter_test/flutter_test.dart';
import 'package:mishka_app/features/chat_with_mishka/data/ai_study_text_extractor.dart';
import 'package:mishka_app/features/chat_with_mishka/data/tool_data_normalizer.dart';

void main() {
  test('quiz payload is not rewritten as summary', () {
    final normalized = normalizeToolData({
      'tool_type': 'quizzes',
      'text': 'Quiz title',
      'questions': [
        {
          'questionText': 'What is 2+2?',
          'options': ['3', '4'],
          'correctOptionIndex': 1,
        },
      ],
    });

    expect(normalized['tool_type'], 'quizzes');
    expect(normalized['questions'], isNotEmpty);
    expect(normalized['summaryText'], isNull);
  });

  test('summary prefers long content body over short text label', () {
    final normalized = normalizeToolData({
      'tool_type': 'summaries',
      'text': 'Generated Summary',
      'content': 'This is the real summary body about the uploaded PDF.',
    });

    expect(
      normalized['summaryText'],
      'This is the real summary body about the uploaded PDF.',
    );
  });

  test('upload explanation unwraps nested payload and structured explanation', () {
    final text = AiStudyTextExtractor.extractUploadExplanation({
      'data': {
        'session_id': 'abc',
        'explanation': {
          'content': 'Nested explanation about chapter 3.',
        },
      },
    });

    expect(text, 'Nested explanation about chapter 3.');
  });
}
