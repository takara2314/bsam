import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/androidId.dart';
import 'package:sailing_assist_mie/providers/deviceName.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:flutter_compass/flutter_compass.dart';

class RaceNavi extends HookConsumerWidget {
  const RaceNavi({Key? key, required String this.raceId}) : super(key: key);
  final String raceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;
    final androidId = ref.watch(androidIdProvider.notifier);
    final deviceName = ref.watch(deviceNameProvider.notifier);

    final raceName = useState<String>('');
    final latitude = useState<double>(20.0);
    final longitude = useState<double>(20.0);
    final nextMarks = useState<int>(-1);
    final nextPointLat = useState<double>(-1);
    final nextPointLng = useState<double>(-1);
    final distance = useState<double>(-1);
    final mapDirection = useState<double>(0);
    final deviceDirection = useState<double>(0);
    final compassDirection = useState<double>(0);
    final compassDirectionName = useState<String>('');

    const marks = {
      -1: '現在取得中…',
      1: '① 上マーク',
      2: '② サイドマーク',
      3: '③ 下マーク'
    };

    useEffect(() {
      try {
        http.get(
          Uri.parse('http://10.0.2.2:8080/race/${raceId}')
        )
          .then((res) {
            if (res.statusCode != 200) {
              throw Exception('Something occurred.');
            }
            final body = json.decode(res.body);
            raceName.value = body['race']['name'];
          });
      } catch (_) {}
    }, const []);

    useEffect(() {
      WebSocket.connect('ws://10.0.2.2:8080/racing/${raceId}?device=${androidId.state}').then((ws) {
        var channel = IOWebSocketChannel(ws);

        Timer.periodic(const Duration(seconds: 5), (Timer? timer) async {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high
          );
          latitude.value = position.latitude;
          longitude.value = position.longitude;

          channel.sink.add(json.encode({
            "latitude": position.latitude,
            "longitude": position.longitude
          }));
        });

        channel.stream.listen((message) {
          final body = json.decode(message);
          nextMarks.value = body['now']['point'];
          nextPointLat.value = body['now']['latitude'];
          nextPointLng.value = body['now']['longitude'];
        });

        FlutterCompass.events?.listen((value) {
          deviceDirection.value = value.accuracy ?? 0;
        });
      });
    }, const []);

    useEffect(() {
      distance.value = Geolocator.distanceBetween(latitude.value, longitude.value, nextPointLat.value, nextPointLng.value);
      mapDirection.value = Geolocator.bearingBetween(latitude.value, longitude.value, nextPointLat.value, nextPointLng.value);
    }, [latitude.value, longitude.value, nextPointLat.value, nextPointLng.value]);

    useEffect(() {
      double direction = deviceDirection.value - mapDirection.value + 270;
      compassDirection.value = direction;

      debugPrint(direction.toString());
      if (direction >= 337.5 || direction < 22.5) {
        compassDirectionName.value = '右';
      } else if (direction >= 22.5 && direction < 67.5) {
        compassDirectionName.value = '右前方';
      } else if (direction >= 67.5 && direction < 112.5) {
        compassDirectionName.value = '上';
      } else if (direction >= 112.5 && direction < 157.5) {
        compassDirectionName.value = '左前方';
      } else if (direction >= 157.5 && direction < 202.5) {
        compassDirectionName.value = '左';
      } else if (direction >= 202.5 && direction < 247.5) {
        compassDirectionName.value = '左後方';
      } else if (direction >= 247.5 && direction < 292.5) {
        compassDirectionName.value = '下';
      } else if (direction >= 292.5 && direction < 337.5) {
        compassDirectionName.value = '右後方';
      }
    }, [mapDirection.value, deviceDirection.value]);

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
        title: Text(
          raceName.value,
          style: const TextStyle(
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
                painter: _Compass(direction: compassDirection.value)
              )
            )
          ),
          Column(
            children: [
              Text(
                marks[nextMarks.value] ?? '',
                style: const TextStyle(
                  fontSize: 32
                )
              ),
              Container(
                margin: const EdgeInsets.only(top: 25, bottom: 25),
                child: Text(
                  compassDirectionName.value ,
                  style: const TextStyle(
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
                    child: Text(
                      '${distance.value.toInt()}',
                      style: const TextStyle(
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
  const _Compass({required this.direction});
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
