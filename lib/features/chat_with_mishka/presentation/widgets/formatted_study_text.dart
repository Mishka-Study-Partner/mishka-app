import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/app_colors.dart';
import 'study_text_utils.dart';

/// Renders AI explanation text (markdown-lite: headings, bullets, bold, code).
class FormattedStudyText extends StatelessWidget {
  const FormattedStudyText({
    super.key,
    required this.text,
    this.baseStyle,
    this.textAlign = TextAlign.start,
  });

  final String text;
  final TextStyle? baseStyle;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final style = baseStyle ??
        TextStyle(
          fontFamily: 'Pridi',
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          height: 1.45,
          color: AppColors.mainDark,
        );

    final direction = studyTextDirection(text);
    final blocks = _blocks(
      prepareStudyTextForDisplay(text),
      style,
      direction,
    );
    if (blocks.isEmpty) return const SizedBox.shrink();

    return Directionality(
      textDirection: direction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: blocks,
      ),
    );
  }

  List<Widget> _blocks(String raw, TextStyle base, TextDirection direction) {
    final widgets = <Widget>[];
    final lines = raw.split('\n');
    var i = 0;
    final align = studyTextAlign(textAlign, direction);

    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        i++;
        continue;
      }

      if (trimmed.startsWith('```')) {
        final buffer = <String>[];
        i++;
        while (i < lines.length && !lines[i].trim().startsWith('```')) {
          buffer.add(lines[i]);
          i++;
        }
        if (i < lines.length) i++;
        widgets.add(_codeBlock(buffer.join('\n'), base, direction, align));
        widgets.add(SizedBox(height: 8.h));
        continue;
      }

      if (trimmed == '---' || trimmed == '***' || trimmed == '⸻') {
        widgets.add(Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Divider(color: AppColors.mainDark.withValues(alpha: 0.2)),
        ));
        i++;
        continue;
      }

      final heading = RegExp(r'^(#{1,6})\s+(.+)$').firstMatch(trimmed);
      if (heading != null) {
        final level = heading.group(1)!.length;
        final size = switch (level) {
          1 => 17.sp,
          2 => 16.sp,
          3 => 15.sp,
          4 => 14.5.sp,
          _ => 14.sp,
        };
        widgets.add(_heading(heading.group(2)!, base, size, direction, align));
        i++;
        continue;
      }

      if (_isBullet(trimmed)) {
        final bullets = <String>[];
        while (i < lines.length && _isBullet(lines[i].trim())) {
          bullets.add(_stripBullet(lines[i].trim()));
          i++;
        }
        for (final bullet in bullets) {
          final bulletDirection = studyTextDirection(bullet);
          widgets.add(
            Directionality(
              textDirection: bulletDirection,
              child: Padding(
                padding: EdgeInsetsDirectional.only(bottom: 4.h, start: 4.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('•  ', style: base.copyWith(fontWeight: FontWeight.w700)),
                    Expanded(
                      child: _richLine(
                        bullet,
                        base,
                        studyTextAlign(align, bulletDirection),
                        bulletDirection,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        widgets.add(SizedBox(height: 6.h));
        continue;
      }

      final paragraph = <String>[trimmed];
      i++;
      while (i < lines.length) {
        final next = lines[i].trim();
        if (next.isEmpty ||
            RegExp(r'^#{1,6}\s').hasMatch(next) ||
            next == '---' ||
            next == '***' ||
            next == '⸻' ||
            next.startsWith('```') ||
            _isBullet(next)) {
          break;
        }
        paragraph.add(next);
        i++;
      }
      widgets.add(_richLine(paragraph.join(' '), base, align, direction));
      widgets.add(SizedBox(height: 8.h));
    }

    return widgets;
  }

  bool _isBullet(String line) =>
      line.startsWith('* ') ||
      line.startsWith('- ') ||
      RegExp(r'^\d+\.\s').hasMatch(line);

  String _stripBullet(String line) {
    if (line.startsWith('* ') || line.startsWith('- ')) {
      return line.substring(2);
    }
    return line.replaceFirst(RegExp(r'^\d+\.\s'), '');
  }

  Widget _heading(
    String text,
    TextStyle base,
    double size,
    TextDirection direction,
    TextAlign align,
  ) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h, bottom: 6.h),
      child: _richLine(
        text,
        base.copyWith(fontSize: size, fontWeight: FontWeight.w700),
        align,
        direction,
      ),
    );
  }

  Widget _codeBlock(
    String code,
    TextStyle base,
    TextDirection direction,
    TextAlign align,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: AppColors.screenBackground,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.mainDark.withValues(alpha: 0.15)),
      ),
      child: Text(
        code,
        style: base.copyWith(
          fontFamily: 'Courier',
          fontSize: 11.sp,
          height: 1.35,
        ),
        textAlign: align,
        textDirection: direction,
      ),
    );
  }

  Widget _richLine(
    String line,
    TextStyle base,
    TextAlign align,
    TextDirection direction,
  ) {
    return Text.rich(
      TextSpan(children: _inlineSpans(line, base)),
      textAlign: align,
      textDirection: direction,
    );
  }

  List<TextSpan> _inlineSpans(String line, TextStyle base) {
    final spans = <TextSpan>[];
    final pattern = RegExp(
      r'(\*\*(.+?)\*\*|__(.+?)__|`([^`]+)`|\*(.+?)\*|_(.+?)_)',
    );
    var cursor = 0;

    for (final match in pattern.allMatches(line)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: line.substring(cursor, match.start),
          style: base,
        ));
      }

      if (match.group(2) != null) {
        spans.add(TextSpan(
          text: match.group(2),
          style: base.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(3) != null) {
        spans.add(TextSpan(
          text: match.group(3),
          style: base.copyWith(fontWeight: FontWeight.w700),
        ));
      } else if (match.group(4) != null) {
        spans.add(TextSpan(
          text: match.group(4),
          style: base.copyWith(
            fontFamily: 'Courier',
            fontSize: (base.fontSize ?? 14) - 1,
            backgroundColor: AppColors.screenBackground,
          ),
        ));
      } else if (match.group(5) != null) {
        spans.add(TextSpan(
          text: match.group(5),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(6) != null) {
        spans.add(TextSpan(
          text: match.group(6),
          style: base.copyWith(fontStyle: FontStyle.italic),
        ));
      }

      cursor = match.end;
    }

    if (cursor < line.length) {
      final tail = line.substring(cursor);
      if (tail.isNotEmpty) {
        spans.add(TextSpan(text: tail, style: base));
      }
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(text: line, style: base));
    }

    return spans;
  }
}
