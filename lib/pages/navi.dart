import 'package:flutter/material.dart';
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
import 'package:bsam/models/navi.dart';
import 'package:bsam/widgets/compass.dart';
import 'package:bsam/services/navi/compass.dart';
import 'package:bsam/services/navi/mark.dart';

class Navi extends ConsumerStatefulWidget {
  const Navi({Key? key, required this.raceId}) : super(key: key);

  final String raceId;

  @override
  ConsumerState<Navi> createState() => _Navi();
}

class _Navi extends ConsumerState<Navi> {
  static const markNum = 3;

  static const marks = {
    1: ['上マーク', 'かみまーく'],
    2: ['サイドマーク', 'さいどまーく'],
    3: ['下マーク', 'しもまーく']
  };

  final FlutterTts tts = FlutterTts();

  StreamSubscription<CompassEvent>? _compass;
  late WebSocketChannel _channel;
  late Timer _timerSendLoc;
  late Timer _timerPeriodicTts;

  bool _started = false;
  bool _enabledPeriodicTts = true;

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;
  double _heading = 0.0;
  double _compassDeg = 0.0;

  int _nextMarkNo = 0;
  List<MarkPosition> _markPos = [];
  double _routeDistance = 0.0;

  @override
  void initState() {
    super.initState();

    // Screen lock
    Wakelock.enable();

    // Change tts speed
    tts.setSpeechRate(0.7);

    _sendLocation(null);
    _timerSendLoc = Timer.periodic(
      const Duration(seconds: 1),
      _sendLocation
    );

    _compass = FlutterCompass.events?.listen(_changeHeading);

    _timerPeriodicTts = Timer.periodic(
      const Duration(seconds: 7),
      _periodicTts
    );

    _connectWs();
  }

  @override
  void dispose() {
    _timerSendLoc.cancel();
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
      _receiveMarkPos(MarkPositionMsg.fromJson(body));
      break;
    }
  }

  _receiveMarkPos(MarkPositionMsg msg) {
    if (!_started) {
      setState(() {
        _markPos = msg.positions!;
      });

      if (msg.markNum == markNum) {
        setState(() {
          _nextMarkNo = 1;
          _started = true;
        });
      }

      return;
    }

    if (msg.markNum == markNum) {
      setState(() {
        _markPos = msg.positions!;
      });
    } else {
      setState(() {
        _markPos = updateMarksOnEnable(_markPos, msg.positions!);
      });
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

  _sendLocation(Timer? timer) async {
    await _getPosition();
    if (_started) {
      _checkPassed();
    }

    try {
      _channel.sink.add(json.encode({
        'type': 'location',
        'latitude': _lat,
        'longitude': _lng,
        'accuracy': _accuracy,
        'heading': _heading
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

  _changeHeading(CompassEvent evt) {
    double heading = evt.heading ?? 0.0;

    setState(() {
      _heading = heading;
    });

    _changeCompassDeg(heading);
  }

  _changeCompassDeg(double heading) {
    final degFix = ref.read(degFixProvider.notifier);

    if (!_started) {
      return;
    }

    double angle = Geolocator.bearingBetween(
      _lat,
      _lng,
      _markPos[_nextMarkNo - 1].lat!,
      _markPos[_nextMarkNo - 1].lng!,
    );

    if (angle > 180) {
      heading = heading - 360;
    }

    setState(() {
      _compassDeg = heading + degFix.state;
    });
  }

  _periodicTts(Timer? timer) {
    if (!_enabledPeriodicTts || !mounted) {
      return;
    }

    if (_started) {
      tts.speak('${getDegName(_compassDeg)}方向、約${_routeDistance.toInt()}メートル');
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
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) {
                return AlertDialog(
                  title: const Text("本当に戻りますか？"),
                  content: const Text("レースの真っ最中です。前の画面に戻るとレースを中断することになります。"),
                  actions: <Widget>[
                    // ボタン領域
                    TextButton(
                      child: const Text("いいえ"),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text("はい"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          }
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
                        painter: Compass(direction: _compassDeg)
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
