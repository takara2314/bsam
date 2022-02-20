import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/androidId.dart';
import 'package:sailing_assist_mie/providers/deviceName.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class RaceNavi extends HookConsumerWidget {
  const RaceNavi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;
    final androidId = ref.watch(androidIdProvider.notifier);
    final deviceName = ref.watch(deviceNameProvider.notifier);

    final latitude = useState<double>(20.0);
    final longitude = useState<double>(20.0);

    void sendPos(double lat, double lng) async {
      try {
        final res = await http.put(
          Uri.parse('http://10.0.2.2:8080/device/${androidId.state}'),
          headers: {'content-type': 'application/json'},
          body: json.encode({
            'name': deviceName.state,
            'model': 9,
            'latitude': lat,
            'longitude': lng
          })
        );
      } catch (_) {}
    }

    void getPos(Timer? timer) async {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      latitude.value = position.latitude;
      longitude.value = position.longitude;

      sendPos(position.latitude, position.longitude);
    }

    useEffect(() {
      getPos(null);
      Timer.periodic(const Duration(seconds: 5), getPos);
    }, const []);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/races')
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
              ),
              Text(
                '緯度 ${latitude.value}',
              ),
              Text(
                '緯度 ${longitude.value}',
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
          - startRadius * sin(pi * theta / 180) + (size.width / 2)
        ),
        Offset(
          endRadius * cos(pi * theta / 180) + (size.width / 2),
          - endRadius * sin(pi * theta / 180) + (size.width / 2)
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
