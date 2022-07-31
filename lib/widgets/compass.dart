import 'package:flutter/material.dart';
import 'dart:math';

class Compass extends CustomPainter {
  const Compass({required this.direction});
  final double direction;

  @override
  void paint(Canvas canvas, Size size) {
    const lineLength = 30;
    final startRadius = (size.width / 2) - lineLength - 10;
    final endRadius = (size.width / 2) - 10;

    final paint = Paint();
    paint.color = Colors.white;
    paint.strokeWidth = 5;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint
    );

    paint.color = const Color.fromRGBO(181, 181, 181, 1);

    for (var theta = 0; theta < 360; theta+=30) {
      canvas.drawLine(
        Offset(
          startRadius * cos(pi * theta / 180) + (size.width / 2),
          - startRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        Offset(
          endRadius * cos(pi * theta / 180) + (size.width / 2),
          - endRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        paint
      );
    }

    final path = Path();
    path.moveTo(
      startRadius * cos(pi * direction / 180) + (size.width / 2),
      - startRadius * sin(pi * direction / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (direction + 160) / 180) + (size.width / 2),
      - startRadius * sin(pi * (direction + 160) / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (direction + 200) / 180) + (size.width / 2),
      - startRadius * sin(pi * (direction + 200) / 180) + (size.width / 2)
    );

    path.close();

    paint.color = const Color.fromRGBO(0, 94, 115, 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
