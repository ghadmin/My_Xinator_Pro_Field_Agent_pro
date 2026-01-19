import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget(
      {super.key,
      this.style,
      required this.text,
      this.maxLines = 1,
      this.textAlign = TextAlign.left,
      this.overflow = TextOverflow.ellipsis});
  final String text;
  final TextStyle? style;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return Text(text,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: overflow,
        textScaler: TextScaler.linear(1.0),
        style: style ?? DefaultTextStyle.of(context).style);
  }
}
