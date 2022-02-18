import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';

class RaceNavi extends HookConsumerWidget {
  const RaceNavi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/select-race')
        ),
        centerTitle: false,
        title: const Text(
          '伊勢湾レースA',
          style: TextStyle(
            color: Colors.black
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent
      ),
      body: Column(
        children: [
          // SizedBox(
          //   width: _width,
          //   height: 350,
          //   child: Stack(
          //     children: [
          //       // Container(
          //       //   margin: const EdgeInsets.all(30),
          //       //   decoration: const BoxDecoration(
          //       //     color: Colors.white,
          //       //     shape: BoxShape.circle
          //       //   ),
          //       // ),
          //       SizedBox(
          //         width: 200,
          //         height: 200,
          //         child: CustomPaint(
          //           painter: _Compass()
          //         )
          //       )
          //     ]
          //   ),
          // ),
          Container(
            margin: const EdgeInsets.only(top: 30, bottom: 30),
            child: SizedBox(
              width: 300,
              height: 300,
              child: CustomPaint(
                painter: _Compass()
              )
            )
          ),
          Column(
            children: [
              const Text(
                '② サイドマーク',
                style: TextStyle(
                  fontSize: 32
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 25, bottom: 25),
                child: const Text(
                  '右',
                  style: TextStyle(
                    color: Color.fromRGBO(0, 94, 115, 1),
                    fontWeight: FontWeight.w900,
                    fontSize: 52
                  )
                )
              ),
              Row(
                children: [
                  const Text(
                    '残り 約',
                    style: TextStyle(
                      color: Color.fromRGBO(79, 79, 79, 1),
                      fontSize: 32
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: const Text(
                      '17',
                      style: TextStyle(
                        color: Color.fromRGBO(79, 79, 79, 1),
                        fontSize: 48
                      )
                    )
                  ),
                  const Text(
                    'm',
                    style: TextStyle(
                      color: Color.fromRGBO(79, 79, 79, 1),
                      fontSize: 32
                    )
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
              )
            ]
          )
        ]
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}


class _Compass extends CustomPainter {
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
          startRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        Offset(
          endRadius * cos(pi * theta / 180) + (size.width / 2),
          endRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        paint
      );
    }

    const direction = 90;

    final path = Path();
    path.moveTo(
      startRadius * cos(pi * direction / 180) + (size.width / 2),
      - startRadius * sin(pi * direction / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (direction + 135) / 180) + (size.width / 2),
      - startRadius * sin(pi * (direction + 135) / 180) + (size.width / 2)
    );

    path.lineTo(
      startRadius * cos(pi * (direction + 225) / 180) + (size.width / 2),
      - startRadius * sin(pi * (direction + 225) / 180) + (size.width / 2)
    );

    path.close();

    // path.moveTo(0, 0);
    // path.lineTo(10, 10);
    // path.lineTo(0, 10);
    // path.close();

    paint.color = const Color.fromRGBO(0, 94, 115, 1);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
