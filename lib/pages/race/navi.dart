import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:sailing_assist_mie/utils/get_deg_name.dart';
import 'package:sailing_assist_mie/utils/normalize_deg.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock/wakelock.dart';
import 'package:sailing_assist_mie/providers.dart';
import 'package:sailing_assist_mie/utils/get_position.dart';

class Navi extends ConsumerStatefulWidget {
  const Navi({Key? key, required this.raceId, required this.raceName}) : super(key: key);

  final String raceId;
  final String raceName;

  @override
  ConsumerState<Navi> createState() => _Navi();
}

class _Navi extends ConsumerState<Navi> {
  static const marks = {
    -1: '現在取得中…',
    1: '① 上マーク',
    2: '② サイドマーク',
    3: '③ 下マーク'
  };

  late Timer _timer;
  StreamSubscription<CompassEvent>? _compass;
  late WebSocketChannel _channel;
  late Timer _compassEasingTimer;

  double _latitude = 0.0;
  double _longitude = 0.0;
  double _compassDeg = 0.0;
  double _routeDeg = 0.0;
  double _compassPinDeg = 0.0;

  int _nextPointNo = -1;
  double _routeDistance = 0.0;
  String _routeDirection = '';

  @override
  void initState() {
    super.initState();

    // Screen lock
    Wakelock.enable();

    _sendPosition(null);
    _timer = Timer.periodic(
      const Duration(seconds: 5),
      _sendPosition
    );

    _compass = FlutterCompass.events?.listen(_getCompassDeg);

    _compassEasingTimer = Timer.periodic(
      const Duration(milliseconds: 1),
      _compassEasing
    );

    _connectWs();
  }

  @override
  void dispose() {
    _timer.cancel();
    _compassEasingTimer.cancel();
    _compass!.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
    super.dispose();
  }

  _sendPosition(Timer? timer) async {
    final pos = await getPosition();

    if (!mounted) {
      return;
    }

    setState(() {
      _latitude = pos[0];
      _longitude = pos[1];
    });

    _channel.sink.add(json.encode({
      'latitude': pos[0],
      'longitude': pos[1]
    }));
  }

  _getCompassDeg(CompassEvent evt) {
    setState(() {
      _compassDeg = evt.heading ?? 0.0;
    });
  }

  _compassEasing(Timer? timer) {
    _compassPinDeg += (_routeDeg - _compassPinDeg) * 0.005;
  }

  _connectWs() {
    if (!mounted) {
      return;
    }

    final userId = ref.read(userIdProvider);
    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/racing/${widget.raceId}?user=$userId'),
      pingInterval: const Duration(seconds: 1)
    );

    _channel.stream.listen(_readWsMsg,
      onDone: () {
        _connectWs();
      }
    );
  }

  _readWsMsg(dynamic message) {
    final body = json.decode(message);

    if (!body.containsKey('next')) {
      return;
    }

    setState(() {
      _nextPointNo = body['next']['point'];
    });

    if (body['next']['latitude'].runtimeType == int || body['next']['longitude'].runtimeType == int) {
      return;
    }

    _calcRoute(
      body['next']['latitude'],
      body['next']['longitude']
    );
  }

  _calcRoute(double nextLat, double nextLng) {
    setState(() {
      _routeDistance = Geolocator.distanceBetween(_latitude, _longitude, nextLat, nextLng);
    });

    final mapDeg = Geolocator.bearingBetween(_latitude, _longitude, nextLat, nextLng);

    // Compass direction
    _routeDeg = normalizeRouteDeg(normalizeDeg(mapDeg) - normalizeCompassDeg(_compassDeg));

    setState(() {
      _routeDirection = getDegName(_routeDeg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.raceName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop()
        )
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 30, bottom: 30),
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(
                  painter: _Compass(direction: _compassPinDeg)
                )
              )
            ),
            Column(
              children: [
                Text(
                  marks[_nextPointNo] ?? '',
                  style: const TextStyle(
                    fontSize: 28
                  )
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    _routeDirection,
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
                        fontSize: 28
                      )
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10, right: 10),
                      child: Text(
                        '${_routeDistance.toInt()}',
                        style: const TextStyle(
                          color: Color.fromRGBO(79, 79, 79, 1),
                          fontSize: 36
                        )
                      )
                    ),
                    const Text(
                      'm',
                      style: TextStyle(
                        color: Color.fromRGBO(79, 79, 79, 1),
                        fontSize: 28
                      )
                    )
                  ],
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                ),
                // Text(
                //   '緯度: $_latitude / 経度: $_longitude'
                // ),
                // Text(
                //   'コンパス角度: $_routeDeg'
                // )
              ]
            )
          ]
        )
      )
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
