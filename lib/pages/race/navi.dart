import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
          SizedBox(
            width: _width,
            height: 350,
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.all(30),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle
                  ),
                )
              ]
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 30),
            child: Column(
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
    final paint = Paint();
    paint.color = Colors.blue;

    canvas.drawCircle(
      const Offset(100, 35),
      25,
      paint
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
