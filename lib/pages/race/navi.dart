import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/androidId.dart';
import 'package:sailing_assist_mie/providers/userId.dart';
import 'package:sailing_assist_mie/providers/deviceName.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:wakelock/wakelock.dart';

class RaceNavi extends HookConsumerWidget {
  const RaceNavi({Key? key, required String this.raceId}) : super(key: key);
  final String raceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;
    final androidId = ref.watch(androidIdProvider.notifier);
    final userId = ref.watch(userIdProvider.notifier);
    final deviceName = ref.watch(deviceNameProvider.notifier);

    final raceName = useState<String>('');
    final latitude = useState<double>(20.0);
    final longitude = useState<double>(20.0);
    final nextPointNo = useState<int>(-1);
    final nextPointLat = useState<double>(34.298093);
    final nextPointLng = useState<double>(136.751886);
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
          Uri.parse('https://sailing-assist-mie-api.herokuapp.com/race/${raceId}')
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
      Wakelock.enable();
      WebSocketChannel channel = IOWebSocketChannel.connect(
        Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/racing/${raceId}?user=${userId.state}')
      );

      getPos(Timer? timer) async {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
        );
        latitude.value = position.latitude;
        longitude.value = position.longitude;

        channel.sink.add(json.encode({
          "latitude": position.latitude,
          "longitude": position.longitude
        }));

        debugPrint(json.encode({
          "latitude": position.latitude,
          "longitude": position.longitude
        }));
      }

      getPos(null);
      final timer = Timer.periodic(const Duration(seconds: 5), getPos);

      channel.stream.listen((message) {
        final body = json.decode(message);
        nextPointNo.value = body['next']['point'];
        // nextPointLat.value = body['next']['latitude'];
        // nextPointLng.value = body['next']['longitude'];
      });

      final stream = FlutterCompass.events?.listen((value) {
        deviceDirection.value = value.heading ?? 0;
      },
        onError: (error) {
          debugPrint('エラーです！');
          debugPrint(error);
        }
      );

      return () {
        debugPrint('廃車や！');
        timer.cancel();
        channel.sink.close();
        stream!.cancel();
        Wakelock.disable();
      };
    }, const []);

    useEffect(() {
      distance.value = Geolocator.distanceBetween(latitude.value, longitude.value, nextPointLat.value, nextPointLng.value);
      mapDirection.value = Geolocator.bearingBetween(latitude.value, longitude.value, nextPointLat.value, nextPointLng.value);
    }, [latitude.value, longitude.value, nextPointLat.value, nextPointLng.value]);

    useEffect(() {
      // compass direction
      double direction = mapDirection.value - deviceDirection.value;

      // Convert to a unit circle angle.
      if (direction >= -180 && direction <= 90) {
        direction = 90 - direction;
      } else {
        direction = 450 - direction;
      }

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
            margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
            child: SizedBox(
              width: 250.h,
              height: 250.h,
              child: CustomPaint(
                painter: _Compass(direction: compassDirection.value)
              )
            )
          ),
          Column(
            children: [
              Text(
                marks[nextPointNo.value] ?? '',
                style: TextStyle(
                  fontSize: 28.sp
                )
              ),
              Container(
                margin: EdgeInsets.only(top: 10.h, bottom: 10.h),
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
                  Text(
                    '残り 約',
                    style: TextStyle(
                      color: const Color.fromRGBO(79, 79, 79, 1),
                      fontSize: 28.sp
                    )
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 10, right: 10),
                    child: Text(
                      '${distance.value.toInt()}',
                      style: TextStyle(
                        color: const Color.fromRGBO(79, 79, 79, 1),
                        fontSize: 36.sp
                      )
                    )
                  ),
                  Text(
                    'm',
                    style: TextStyle(
                      color: const Color.fromRGBO(79, 79, 79, 1),
                      fontSize: 28.sp
                    )
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
              Text(
                '緯度 ${latitude.value} / 経度 ${longitude.value}',
              ),
              Text(
                'マ角度 ${mapDirection.value}',
              ),
              Text(
                'デ角度 ${deviceDirection.value}',
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
