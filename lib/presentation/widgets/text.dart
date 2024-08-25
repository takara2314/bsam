import 'package:flutter/material.dart';

class NormalText extends StatelessWidget {
  final String text;
  final TextAlign? textAlign;

  const NormalText(
    this.text,
    {
      this.textAlign,
      super.key
    }
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 62, 62, 62),
        fontSize: 16
      ),
      textAlign: textAlign
    );
  }
}

class Heading extends StatelessWidget {
  final String text;

  const Heading(
    this.text,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Color.fromARGB(255, 62, 62, 62),
        fontWeight: FontWeight.bold,
        fontSize: 20
      )
    );
  }
}
