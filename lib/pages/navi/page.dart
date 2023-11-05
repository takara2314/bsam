import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock/wakelock.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:battery_plus/battery_plus.dart';

import 'package:bsam/providers.dart';
import 'package:bsam/models/mark.dart';
import 'package:bsam/models/mark_position_msg.dart';
import 'package:bsam/services/navi/compass.dart';
import 'package:bsam/services/navi/mark.dart';
import 'package:bsam/pages/navi/navigating.dart';
import 'package:bsam/pages/navi/waiting.dart';
import 'package:bsam/pages/navi/app_bar.dart';
import 'package:bsam/pages/navi/pop_dialog.dart';

class Navi extends ConsumerStatefulWidget {
  const Navi({
    super.key,
    required this.assocId,
    required this.userId,
    required this.ttsSpeed,
    required this.ttsDuration,
    required this.headingFix,
    required this.isAnnounceNeighbors
  });

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
  static const maxDistance = 10000;

  static const markNames = {
    1: ['上', 'かみ'],
    2: ['サイド', 'さいど'],
    3: ['下', 'しも']
  };

  final FlutterTts tts = FlutterTts();
  final Battery battery = Battery();

  StreamSubscription<CompassEvent>? _compass;
  late WebSocketChannel _channel;

  bool _started = false;
  bool _enabledPeriodicAnnounce = true;

  double _lat = 0.0;
  double _lng = 0.0;
  double _accuracy = 0.0;
  double _heading = 0.0;
  double _compassDeg = 0.0;

  int _nextMarkNo = 1;
  List<Mark> _marks = [];
  double _routeDistance = 0.0;
  bool _reconnected = false;

  // DateTime? _lastPassedTime;

  @override
  void initState() {
    super.initState();

    // Init text to speech
    _initTts();

    // Screen lock
    Wakelock.enable();

    // Change tts volume
    tts.setVolume(1.0);

    // Change tts speed
    tts.setSpeechRate(widget.ttsSpeed);

    _compass = FlutterCompass.events?.listen(_changeHeading);

    _initIsolate();

    _connectWs();
  }

  @override
  void dispose() {
    tts.pause();
    _compass!.cancel();
    _channel.sink.close(status.goingAway);
    Wakelock.disable();
    super.dispose();
  }

  _initTts() async {
    await tts.setLanguage("ja-JP");
    await tts.setSpeechRate(widget.ttsSpeed);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);
    await tts.awaitSpeakCompletion(true);
  }

  _initIsolate() async {
    _announceIsolate((widget.ttsDuration * 1000).toInt());
    _sendLocationIsolate(1000);
    _sendBatteryIsolate(10000);
  }

  _announceIsolate(int interval) async {
    while (true) {
      if (!mounted) {
        return;
      }
      await _announce();
      await Future.delayed(Duration(milliseconds: interval));
    }
  }

  _sendLocationIsolate(int interval) async {
    while (true) {
      if (!mounted) {
        return;
      }
      await _sendLocation();
      await Future.delayed(Duration(milliseconds: interval));
    }
  }

  _sendBatteryIsolate(int interval) async {
    while (true) {
      if (!mounted) {
        return;
      }
      await _sendBattery();
      await Future.delayed(Duration(milliseconds: interval));
    }
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
          setState(() {
            _reconnected = true;
          });
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
    case 'auth_result':
      _receiveAuth(body);
      break;

    case 'mark_position':
      _receiveMarkPos(MarkPositionMsg.fromJson(body));
      break;

    case 'near_sail':
      _receiveNearSail(body);
      break;

    case 'start_race':
      _receiveStartRace(body);
      break;

    case 'set_next_mark_no':
      _receiveSetMarkNo(body);
      break;
    }
  }

  _receiveAuth(dynamic msg) {
    if (msg['link_type'] != 'restore') {
      return;
    }

    if (_reconnected) {
      int oldMarkNo = _nextMarkNo - 1;
      if (oldMarkNo == 0) {
        oldMarkNo = markNum;
      }
      _sendPassed(oldMarkNo, _nextMarkNo);

    } else {
      setState(() {
        _nextMarkNo = msg['next_mark_no'];
      });
    }
  }

  _receiveMarkPos(MarkPositionMsg msg) {
    if (!_started) {
      setState(() {
        _marks = msg.marks!;
      });
      return;
    }

    if (msg.markNum == markNum) {
      setState(() {
        _marks = msg.marks!;
      });
    } else {
      setState(() {
        // 送られてきた緯度経度が0.0のものは更新しない
        _marks = updateMarksOnEnable(_marks, msg.marks!);
      });
    }
  }

  _receiveNearSail(dynamic msg) {
    if (!_started || !widget.isAnnounceNeighbors) {
      return;
    }

    // setState(() {
    //   _nearSailNum = msg['neighbors'].length;
    // });
  }

  _receiveStartRace(dynamic msg) {
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

    if (pos.accuracy > 30.0 || !mounted) {
      return;
    }

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _accuracy = pos.accuracy;
    });
  }

  _sendLocation() async {
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
        'heading_fixing': widget.headingFix
      }));
    } catch (_) {}
  }

  _sendBattery() async {
    final level = await _getBattery();

    try {
      _channel.sink.add(json.encode({
        'type': 'battery',
        'level': level
      }));
    } catch (_) {}
  }

  _checkPassed() {
    if (_lat == 0.0 && _lng == 0.0) {
      return;
    }

    double diff = Geolocator.distanceBetween(
      _lat,
      _lng,
      _marks[_nextMarkNo - 1].position!.lat!,
      _marks[_nextMarkNo - 1].position!.lng!,
    );

    setState(() {
      _routeDistance = diff;
    });

    if (diff > 20.0) {
      return;
    }

    // Passed mark
    _onPassed();
  }

  _onPassed() {
    int oldMarkNo = _nextMarkNo;
    int nextMarkNo = oldMarkNo % 3 + 1;

    setState(() {
      // _lastPassedTime = DateTime.now();
      _nextMarkNo = nextMarkNo;
    });

    _sendPassed(oldMarkNo, nextMarkNo);
    _passedAnnounce(oldMarkNo);
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

    setState(() {
      _compassDeg = _calcCompassDeg(heading);
    });
  }

  double _calcCompassDeg(double heading) {
    if (!_started) {
      return 0;
    }

    double bearingDeg = Geolocator.bearingBetween(
      _lat,
      _lng,
      _marks[_nextMarkNo - 1].position!.lat!,
      _marks[_nextMarkNo - 1].position!.lng!,
    );

    double diff = bearingDeg - heading;

    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    return diff;
  }

  _speak(String text) async {
    try {
      // TTSの仕様で 46 のみ英語の発音なので、ひらがな読みにする
      text = text.replaceAll('46', 'よんじゅうろく');

      await tts.speak(text);
    } catch (e) {
      debugPrint('error!');
      debugPrint(e.toString());
      await _initTts();
    }
  }

  _announce() async {
    // If not started, skip tts
    if (!_started) {
      return;
    }

    // If stopped periodic tts, skip tts
    if (!_enabledPeriodicAnnounce) {
      return;
    }

    String text = '${markNames[_nextMarkNo]![1]}、${getDegName(_compassDeg)}、${_routeDistance.toInt()}';
    // If route distance is over max distance, announce 'unknown'
    if (_routeDistance >= maxDistance) {
      text = '向き、距離、不明';
    }

    await _speak(text);
  }

  _passedAnnounce(int markNo) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _enabledPeriodicAnnounce = false;
    });

    for (int i = 0; i < 5; i++) {
      await _speak('${markNames[markNo]![1]}に到達');
      await Future.delayed(const Duration(seconds: 1));
    }

    setState(() {
      _enabledPeriodicAnnounce = true;
    });
  }

  _forcePassed(int markNo) {
    int oldMarkNo = _nextMarkNo;
    int nextMarkNo = markNo % 3 + 1;

    _sendPassed(oldMarkNo, nextMarkNo);

    setState(() {
      _nextMarkNo = nextMarkNo;
    });
  }

  Future<int> _getBattery() async {
    return await battery.batteryLevel;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        isPopDialog(context);
        return false;
      },
      child: Scaffold(
        appBar: const NaviAppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (_started
              ? Navigating(
                  latitude: _lat,
                  longitude: _lng,
                  accuracy: _accuracy,
                  heading: _heading,
                  compassDeg: _compassDeg,
                  markNames: markNames,
                  nextMarkNo: _nextMarkNo,
                  routeDistance: _routeDistance,
                  maxDistance: maxDistance,
                  forcePassed: _forcePassed,
                  onPassed: _onPassed
                )
              : Waiting(
                  latitude: _lat,
                  longitude: _lng,
                  accuracy: _accuracy,
                  heading: _heading,
                  compassDeg: _compassDeg
              )
            )
          ]
        )
      )
    );
  }
}
