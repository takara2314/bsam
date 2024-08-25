import 'package:bsam/main.dart';
import 'package:flutter/material.dart';

class NormalText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;

  const NormalText(
    this.text,
    {
      this.textAlign,
      this.color,
      this.fontSize,
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? bodyTextColor,
        fontSize: fontSize ?? bodyTextSize
      ),
      textAlign: textAlign
    );
  }
}

class Heading extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;
  final Color? color;
  final double? fontSize;

  const Heading(
    this.text,
    {
      this.textAlign,
      this.color,
      this.fontSize,
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? bodyTextColor,
        fontWeight: FontWeight.bold,
        fontSize: fontSize ?? bodyHeadingSize
      )
    );
  }
}
