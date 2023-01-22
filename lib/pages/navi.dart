import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:wavenet/wavenet.dart';

import 'package:bsam/providers.dart';
import 'package:bsam/models/position.dart' as mark;
import 'package:bsam/models/mark_position_msg.dart';
import 'package:bsam/widgets/compass.dart';
import 'package:bsam/services/navi/compass.dart';
import 'package:bsam/services/navi/mark.dart';

class Navi extends ConsumerStatefulWidget {
  const Navi({
    Key? key,
    required this.assocId,
    required this.userId,
    required this.ttsSpeed,
    required this.ttsDuration,
    required this.headingFix,
    required this.isAnnounceNeighbors
  }) : super(key: key);

  final String assocId;
  final String userId;
  final double ttsSpeed;
  final double ttsDuration;
  final double headingFix;
  final bool isAnnounceNeighbors;

  @override
  ConsumerState<Navi> createState() => _Navi();
}

class _Navi extends ConsumerState<Navi> {
  static const markNum = 3;

  static const marks = {
    1: ['上', 'かみ'],
    2: ['サイド', 'さいど'],
    3: ['下', 'しも']
  };

  final FlutterTts tts = FlutterTts();

  StreamSubscription<CompassEvent>? _compass;
  late WebSocketChannel _channel;
  late Timer _timerSendLoc;

  bool _started = false;
  bool _enabledPeriodicTts = true;

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;
  double _heading = 0.0;
  double _compassDeg = 0.0;

  int _nextMarkNo = 1;
  List<mark.Position> _markPos = [];
  double _routeDistance = 0.0;

  int _nearSailNum = 0;

  DateTime? _lastPassedTime;

  late TextToSpeechService _ttsService;
  final audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    // Load wavenet tts
    _loadTts();

    // Screen lock
    Wakelock.enable();

    // Change tts volume
    tts.setVolume(1.0);

    // Change tts speed
    tts.setSpeechRate(widget.ttsSpeed);

    _sendLocation(null);
    _timerSendLoc = Timer.periodic(
      const Duration(milliseconds: 500),
      _sendLocation
    );

    _compass = FlutterCompass.events?.listen(_changeHeading);

    // _timerPeriodicTts = Timer.periodic(
    //   Duration(milliseconds: (widget.ttsDuration * 1000).toInt()),
    //   _periodicTts
    // );
    _periodicTts();

    _connectWs();
  }

  @override
  void dispose() {
    _timerSendLoc.cancel();
    // _timerPeriodicTts.cancel();
    _compass!.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
    super.dispose();
  }

  _loadTts() {
    // Get wavenet token (tts)
    final token = ref.read(wavenetTokenProvider);
    _ttsService = TextToSpeechService(token);
  }

  _connectWs() {
    if (!mounted) {
      return;
    }

    // Get server url
    final serverUrl = ref.read(serverUrlProvider);

    _channel = IOWebSocketChannel.connect(
      Uri.parse('$serverUrl/racing/${widget.assocId}'),
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
        'token': jwt,
        'user_id': widget.userId,
        'role': 'athlete'
      }));
    } catch (_) {}
  }

  _readWsMsg(dynamic msg) {
    final body = json.decode(msg);

    switch (body['type']) {
    case 'mark_position':
      _receiveMarkPos(MarkPositionMsg.fromJson(body));
      break;

    case 'near_sail':
      _receiveNearSail(body);
      break;

    case 'start_race':
      _receiveStartRace(body);
      break;

    case 'set_mark_no':
      _receiveSetMarkNo(body);
      break;
    }
  }

  _receiveMarkPos(MarkPositionMsg msg) {
    if (!_started) {
      setState(() {
        _markPos = msg.positions!;
      });
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

  _receiveNearSail(dynamic msg) {
    if (!_started || !widget.isAnnounceNeighbors) {
      return;
    }

    setState(() {
      _nearSailNum = msg['neighbors'].length;
    });
  }

  _receiveStartRace(dynamic msg) {
    // have started
    if (_started == false && msg['started']) {
      setState(() {
        _nextMarkNo = 1;
      });
    }

    // race status
    setState(() {
      _started = msg['started'];
    });
  }

  _receiveSetMarkNo(dynamic msg) {
    setState(() {
      _nextMarkNo = msg['next_mark_no'];
    });
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
        'heading': _heading,
        'heading_fixing': widget.headingFix,
        'compass_degree': _compassDeg
      }));
    } catch (_) {}
  }

  _checkPassed() {
    double diff = Geolocator.distanceBetween(
      _lat,
      _lng,
      _markPos[_nextMarkNo - 1].lat!,
      _markPos[_nextMarkNo - 1].lng!,
    );

    // Correct error
    diff = max(0.0, diff - 10.0);

    setState(() {
      _routeDistance = diff;
    });

    if (diff > 10.0) {
      return;
    }

    // Passed mark
    _onPassed();
  }

  _onPassed() {
    int nextMarkNo = _nextMarkNo % 3 + 1;

    _sendPassed(_nextMarkNo, nextMarkNo);
    _passedTts(_nextMarkNo);

    setState(() {
      _lastPassedTime = DateTime.now();
      _nextMarkNo = nextMarkNo;
    });
  }

  _sendPassed(int passedMarkNo, int nextMarkNo) {
    try {
      _channel.sink.add(json.encode({
        'type': 'passed',
        'passed_mark_no': passedMarkNo,
        'next_mark_no': nextMarkNo
      }));
    } catch (_) {}
  }

  _changeHeading(CompassEvent evt) {
    double heading = evt.heading ?? 0.0;

    // Correct magnetic declination
    heading += widget.headingFix;

    if (heading > 180.0) {
      heading = -360.0 + heading;
    }

    setState(() {
      _heading = heading;
    });

    _changeCompassDeg(heading);
  }

  _changeCompassDeg(double heading) {
    if (!_started) {
      return;
    }

    double bearingDeg = Geolocator.bearingBetween(
      _lat,
      _lng,
      _markPos[_nextMarkNo - 1].lat!,
      _markPos[_nextMarkNo - 1].lng!,
    );

    double diff = bearingDeg - heading;

    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff = 360 - diff;
    }

    setState(() {
      _compassDeg = diff;
    });
  }

  _periodicTts() async {
    while (true) {
      if (!mounted) {
        return;
      }

      if (!_enabledPeriodicTts) {
        debugPrint('定期アナウンスが中止されているため、アナウンスをスルーします');
        await Future.delayed(Duration(milliseconds: (widget.ttsDuration * 1000).toInt()));
        continue;
      }

      String text = '';

      if (!_started) {
        await Future.delayed(const Duration(milliseconds: 100));
        continue;

      } else {
        text = '${getDegName(_compassDeg)}、${_routeDistance.toInt()}';

        if (_lastPassedTime != null) {
          if (DateTime.now().difference(_lastPassedTime!).inSeconds < 30) {
            text = '${marks[_nextMarkNo]![1]}、$text';
          }
        }
      }

      await _tts(text);
      await Future.delayed(Duration(milliseconds: (widget.ttsDuration * 1000).toInt()));
    }
  }

  _passedTts(int markNo) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _enabledPeriodicTts = false;
    });

    for (int i = 0; i < 5; i++) {
      await _tts('${marks[markNo]![1]}に到達');
      await Future.delayed(const Duration(seconds: 3));
    }

    setState(() {
      _enabledPeriodicTts = true;
    });
  }

  _tts(String text) async {
    text.replaceAll('46', 'よんじゅうろく');

    File file = await _ttsService.textToSpeech(
      text: text,
      voiceName: 'ja-JP-Wavenet-B',
      languageCode: 'ja-JP',
      audioEncoding: 'LINEAR16',
      speakingRate: widget.ttsSpeed,
    );
    try {
      await audioPlayer.play(
        DeviceFileSource(file.path),
        volume: 1.0
      );
    } catch (e) {
      debugPrint(e.toString());
    }
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
    return WillPopScope(
      onWillPop: () async {
        isReturnDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => isReturnDialog(context)
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
                          painter: Compass(heading: _compassDeg)
                        )
                      )
                    ),
                    Text(
                      '$_nextMarkNo ${marks[_nextMarkNo]![0]}マーク',
                      style: const TextStyle(
                        fontSize: 28
                      )
                    ),
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
                      '緯度 / 経度',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '${_lat.toStringAsFixed(6)} / ${_lng.toStringAsFixed(6)}'
                    ),
                    Text(
                      '位置情報の精度',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '${_accuracy.toStringAsFixed(2)} m'
                    ),
                    Text(
                      '端末の方角 / コンパスの方角',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '${_heading.toStringAsFixed(2)}° / ${_compassDeg.toStringAsFixed(2)}°'
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
                        TextButton(
                          onPressed: () {_onPassed();},
                          child: const Text('マーク通過判定')
                        )
                      ]
                    )
                  ]
                )
              : Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(right: 15, left: 15),
                child: Column(
                  children: [
                    Text(
                      'レースは始まっていません',
                      style: Theme.of(context).textTheme.headline1
                    ),
                    const Text(
                      'スタートボタンが押されるまでお待ちください。'
                    ),
                    Text(
                      '緯度 / 経度',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '${_lat.toStringAsFixed(6)} / ${_lng.toStringAsFixed(6)}'
                    ),
                    Text(
                      '位置情報の精度',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '$_accuracy m'
                    ),
                    Text(
                      '端末の方角 / コンパスの方角',
                      style: Theme.of(context).textTheme.headline3
                    ),
                    Text(
                      '${_heading.toStringAsFixed(2)}° / ${_compassDeg.toStringAsFixed(2)}°'
                    )
                  ])
                )
              )
            ]
          )
        )
      )
    );
  }
}

void isReturnDialog(BuildContext context) {
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
            onPressed: () {
              int count = 0;
              Navigator.popUntil(context, (_) => count++ >= 2);
            }
          ),
        ],
      );
    },
  );
}
