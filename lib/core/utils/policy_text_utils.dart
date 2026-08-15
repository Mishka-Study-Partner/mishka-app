import 'package:mishka_app/features/chat_with_mishka/presentation/widgets/study_text_utils.dart';

/// Formats backend privacy-policy plain text for [FormattedStudyText].
String preparePolicyTextForDisplay(String raw) {
  var text = prepareStudyTextForDisplay(raw);
  text = text.replaceAll('⸻', '\n---\n');

  final lines = text.split('\n');
  final out = <String>[];

  for (var i = 0; i < lines.length; i++) {
    final trimmed = lines[i].trim();
    if (trimmed.isEmpty) {
      out.add('');
      continue;
    }
    if (trimmed == '---') {
      out.add('---');
      continue;
    }

    final section = RegExp(r'^(\d+)\.\s+(.+)$').firstMatch(trimmed);
    if (section != null) {
      out.add('## ${section.group(1)}. ${section.group(2)}');
      continue;
    }

    if (_isPolicySubheading(trimmed)) {
      out.add('### $trimmed');
      continue;
    }

    out.add(lines[i]);
  }

  return out.join('\n');
}

bool _isPolicySubheading(String line) {
  if (line.startsWith('* ') || line.startsWith('- ')) return false;
  if (RegExp(r'^\d+\.\s').hasMatch(line)) return false;
  if (line.endsWith('.') || line.endsWith(':') || line.endsWith('?')) {
    return false;
  }
  if (line.length > 56) return false;
  if (!RegExp(r'^[A-Z0-9]').hasMatch(line)) return false;

  final words = line.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty || words.length > 7) return false;

  final capitalizedWords = words.where(
    (word) => RegExp(r'^[A-Z(\[]').hasMatch(word),
  ).length;
  return capitalizedWords >= (words.length * 0.6).ceil();
}
