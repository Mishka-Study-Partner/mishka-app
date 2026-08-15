import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show Bidi;

/// Normalizes AI-generated markdown before rich rendering.
String prepareStudyTextForDisplay(String raw) {
  var text = raw.replaceAll('\r\n', '\n').trim();
  if (text.isEmpty) return text;

  text = text.replaceAllMapped(
    RegExp(r'^[ \t]*[•·◦▪‣]\s*', multiLine: true),
    (_) => '- ',
  );
  text = text.replaceAllMapped(
    RegExp(r'\[([^\]]+)\]\([^)]*\)'),
    (m) => m.group(1) ?? '',
  );
  text = text.replaceAllMapped(
    RegExp(r'!\[[^\]]*\]\([^)]*\)'),
    (_) => '',
  );
  text = text.replaceAllMapped(
    RegExp(r'^(#{1,6})([^\s#])', multiLine: true),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  text = text.replaceAllMapped(
    RegExp(r'^>\s?', multiLine: true),
    (_) => '',
  );
  text = text.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
  text = text.replaceAll('&nbsp;', ' ');
  text = text.replaceAll('&amp;', '&');
  text = text.replaceAll('&lt;', '<');
  text = text.replaceAll('&gt;', '>');

  return text;
}

/// Plain readable study copy — strips markdown symbols for plain-text fallbacks.
String plainStudyText(String raw) {
  final prepared = prepareStudyTextForDisplay(raw);
  final lines = prepared.split('\n');
  final out = <String>[];
  var inCode = false;

  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.startsWith('```')) {
      inCode = !inCode;
      continue;
    }
    if (inCode) {
      out.add(trimmed);
      continue;
    }
    if (trimmed.isEmpty || trimmed == '---' || trimmed == '***') {
      if (out.isNotEmpty && out.last.isNotEmpty) out.add('');
      continue;
    }
    var text = trimmed;
    final heading = RegExp(r'^#{1,6}\s+').firstMatch(text);
    if (heading != null) {
      text = text.substring(heading.end);
    }
    if (text.startsWith('* ') || text.startsWith('- ')) {
      text = text.substring(2);
    } else {
      text = text.replaceFirst(RegExp(r'^\d+\.\s'), '');
    }
    text = _stripInlineMarkdown(text);
    if (text.isNotEmpty) out.add(text);
  }

  return out.join('\n\n').trim();
}

String _stripInlineMarkdown(String text) {
  var result = text;
  result = result.replaceAllMapped(
    RegExp(r'\*\*(.+?)\*\*'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAllMapped(
    RegExp(r'__(.+?)__'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAllMapped(
    RegExp(r'`([^`]+)`'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAllMapped(
    RegExp(r'\*(.+?)\*'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAllMapped(
    RegExp(r'_(.+?)_'),
    (m) => m.group(1) ?? '',
  );
  result = result.replaceAll('**', '').replaceAll('__', '').replaceAll('`', '');
  result = result.replaceAll('*', '').replaceAll('_', '');
  return result.trim();
}

String formatChatTime(DateTime time) {
  final hour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
  final minute = time.minute.toString().padLeft(2, '0');
  final period = time.hour >= 12 ? 'pm' : 'am';
  return '$hour:$minute $period';
}

/// Detects reading direction for AI-generated study copy.
TextDirection studyTextDirection(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return TextDirection.ltr;
  return Bidi.detectRtlDirectionality(trimmed)
      ? TextDirection.rtl
      : TextDirection.ltr;
}

/// Maps requested alignment to a direction-aware value (justify breaks Arabic).
TextAlign studyTextAlign(TextAlign requested, TextDirection direction) {
  return switch (requested) {
    TextAlign.start || TextAlign.end => requested,
    TextAlign.left =>
      direction == TextDirection.rtl ? TextAlign.right : TextAlign.left,
    TextAlign.right =>
      direction == TextDirection.rtl ? TextAlign.left : TextAlign.right,
    TextAlign.justify =>
      direction == TextDirection.rtl ? TextAlign.start : TextAlign.justify,
    _ => requested,
  };
}

/// Plain [Text] with automatic RTL/LTR for AI-generated strings.
class StudyText extends StatelessWidget {
  const StudyText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  @override
  Widget build(BuildContext context) {
    final direction = studyTextDirection(data);
    return Text(
      data,
      style: style,
      textAlign: studyTextAlign(textAlign ?? TextAlign.start, direction),
      textDirection: direction,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}
