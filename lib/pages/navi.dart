import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_tts/flutter_tts.dart';

import 'package:bsam/providers.dart';

class Navi extends ConsumerStatefulWidget {
  const Navi({Key? key, required this.raceId}) : super(key: key);

  final String raceId;

  @override
  ConsumerState<Navi> createState() => _Navi();
}

class _Navi extends ConsumerState<Navi> {
  static const marks = {
    1: ['上マーク', 'かみまーく'],
    2: ['サイドマーク', 'さいどまーく'],
    3: ['下マーク', 'しもまーく']
  };

  final FlutterTts tts = FlutterTts();

  StreamSubscription<CompassEvent>? _compass;
  late WebSocketChannel _channel;
  late Timer _timerSendPos;
  late Timer _timerPeriodicTts;

  bool _started = false;
  bool _enabledPeriodicTts = true;

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;
  double _compassDeg = 0.0;

  int _nextMarkNo = 0;
  final List<MarkPosition> _markPos = [];
  double _routeDistance = 0.0;

  @override
  void initState() {
    super.initState();

    // Screen lock
    Wakelock.enable();

    // Change tts speed
    tts.setSpeechRate(0.7);

    _sendPosition(null);
    _timerSendPos = Timer.periodic(
      const Duration(seconds: 1),
      _sendPosition
    );

    _compass = FlutterCompass.events?.listen(_changeCompassDeg);

    _timerPeriodicTts = Timer.periodic(
      const Duration(seconds: 7),
      _periodicTts
    );

    _connectWs();
  }

  @override
  void dispose() {
    _timerSendPos.cancel();
    _timerPeriodicTts.cancel();
    _compass!.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
    super.dispose();
  }

  _connectWs() {
    if (!mounted) {
      return;
    }

    _channel = IOWebSocketChannel.connect(
      Uri.parse('wss://sailing-assist-mie-api.herokuapp.com/v2/racing/${widget.raceId}'),
      pingInterval: const Duration(seconds: 1)
    );

    _channel.stream.listen(_readWsMsg,
      onDone: () {
        if (mounted) {
          debugPrint('reconnect');
          _connectWs();
        }
      }
    );

    final jwt = ref.read(jwtProvider);
    try {
      _channel.sink.add(json.encode({
        'type': 'auth',
        'token': jwt
      }));
    } catch (_) {}
  }

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);

    switch (body['type']) {
    case 'mark_position':
      List<MarkPosition> markPos = [];

      body['positions'].forEach((pos) {
        markPos.add(MarkPosition.fromJson(pos));
      });

      if (markPos.length == 3) {
        setState(() {
          _started = true;
        });
      }

      break;
    }
  }

  _getPosition() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    if (pos.accuracy > 15.0 || !mounted) {
      return;
    }

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _accuracy = pos.accuracy;
    });
  }

  _sendPosition(Timer? timer) async {
    await _getPosition();
    _checkPassed();

    try {
      _channel.sink.add(json.encode({
        'type': 'position',
        'latitude': _lat,
        'longitude': _lng
      }));
    } catch (_) {}
  }

  _checkPassed() {
    final diff = Geolocator.distanceBetween(
      _lat,
      _lng,
      _markPos[_nextMarkNo - 1].lat!,
      _markPos[_nextMarkNo - 1].lng!,
    );

    setState(() {
      _routeDistance = diff;
    });

    if (diff > 10) {
      return;
    }

    int nextMarkNo = _nextMarkNo % 3 + 1;

    _sendPassed(_nextMarkNo, nextMarkNo);
    _passedTts(_nextMarkNo);

    setState(() {
      _nextMarkNo = nextMarkNo;
    });
  }

  _sendPassed(int markNo, int nextMarkNo) {
    try {
      _channel.sink.add(json.encode({
        'type': 'passed',
        'mark_no': markNo,
        'next_mark_no': nextMarkNo
      }));
    } catch (_) {}
  }

  _changeCompassDeg(CompassEvent evt) {
    double compassDeg = evt.heading ?? 0.0;

    double angle = Geolocator.bearingBetween(
      _lat,
      _lng,
      _markPos[_nextMarkNo - 1].lat!,
      _markPos[_nextMarkNo - 1].lng!,
    );

    if (angle > 180) {
      compassDeg = compassDeg - 360;
    }

    setState(() {
      _compassDeg = compassDeg;
    });
  }

  _periodicTts(Timer? timer) {
    if (!_enabledPeriodicTts || !mounted) {
      return;
    }

    if (_started) {
      tts.speak('約${_routeDistance.toInt()}メートル');
    } else {
      tts.speak('レースは始まっていません');
    }
  }

  _passedTts(int markNo) async {
    setState(() {
      _enabledPeriodicTts = false;
    });

    for (int i = 0; i < 5; i++) {
      tts.speak('${marks[markNo]![1]}に到達');
      await Future.delayed(const Duration(seconds: 3));
    }

    setState(() {
      _enabledPeriodicTts = true;
    });
  }

  _forcePassed(int markNo) {
    int nextMarkNo = markNo % 3 + 1;

    _sendPassed(_nextMarkNo, nextMarkNo);

    setState(() {
      _nextMarkNo = nextMarkNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
            (_started
              ? Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30, bottom: 30),
                    child: SizedBox(
                      width: 250,
                      height: 250,
                      child: CustomPaint(
                        painter: _Compass(direction: _compassDeg)
                      )
                    )
                  ),
                  Text(
                    '$_nextMarkNo ${marks[_nextMarkNo]![0]}',
                    style: const TextStyle(
                      fontSize: 28
                    )
                  ),
                  // Container(
                  //   margin: const EdgeInsets.only(top: 10, bottom: 10),
                  //   child: Text(
                  //     _routeDirection,
                  //     style: const TextStyle(
                  //       color: Color.fromRGBO(0, 94, 115, 1),
                  //       fontWeight: FontWeight.w900,
                  //       fontSize: 52
                  //     )
                  //   )
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
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
                  ),
                  Text(
                    '緯度: $_lat / 経度: $_lng'
                  ),
                  Text(
                    'コンパス角度: $_compassDeg'
                  ),
                  Text(
                    '精度: $_accuracy m'
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {_forcePassed(1);},
                        child: const Text('上通過')
                      ),
                      TextButton(
                        onPressed: () {_forcePassed(2);},
                        child: const Text('サイド通過')
                      ),
                      TextButton(
                        onPressed: () {_forcePassed(3);},
                        child: const Text('下通過')
                      ),
                    ],
                  )
                ]
              )
            : Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Column(
                children: [
                  const Text(
                    'レースは始まっていません',
                    style: TextStyle(
                      fontSize: 28
                    )
                  ),
                  const Text(
                    'スタートボタンが押されるまでお待ちください。'
                  ),
                  Text(
                    '精度: $_accuracy m'
                  )
                ])
              )
            )
          ]
        )
      )
    );
  }
}

class MarkPosition {
  double? lat;
  double? lng;

  MarkPosition({this.lat, this.lng});

  MarkPosition.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'];
    lng = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = lat;
    data['longitude'] = lng;
    return data;
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
