import 'package:flutter/material.dart';

/// Centered button label that wraps to [maxLines] (Arabic / long copy).
class ButtonLabel extends StatelessWidget {
  const ButtonLabel(
    this.text, {
    super.key,
    this.style,
    this.maxLines = 2,
  });

  final String text;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: maxLines,
      softWrap: true,
      overflow: TextOverflow.visible,
      style: style,
    );
  }
}
