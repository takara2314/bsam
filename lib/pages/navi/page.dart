import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:bsam/providers.dart';
import 'package:bsam/models/mark.dart';
import 'package:bsam/models/mark_position_msg.dart';
import 'package:bsam/services/navi/compass.dart';
import 'package:bsam/services/navi/mark.dart';
import 'package:bsam/services/tts_service.dart';
import 'package:bsam/services/location_service.dart';
import 'package:bsam/services/ws_message_service.dart';
import 'package:bsam/constants/app_constants.dart';
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
    required this.reachJudgeRadius,
    required this.reachNoticeNum,
    required this.headingFix,
    required this.isAnnounceNeighbors,
    required this.markNameType
  });

  final String assocId;
  final String userId;
  final double ttsSpeed;
  final double ttsDuration;
  final int reachJudgeRadius;
  final int reachNoticeNum;
  final double headingFix;
  final bool isAnnounceNeighbors;
  final int markNameType;

  @override
  ConsumerState<Navi> createState() => _Navi();
}

class _Navi extends ConsumerState<Navi> {
  late Map<int, List<String>> markNames;
  late TtsService ttsService;
  late LocationService locationService;
  late WsMessageService messageService;

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

    // Mark names initialization based on type
    markNames = widget.markNameType == 0
        ? AppConstants.standardMarkNames
        : AppConstants.numericMarkNames;

    // サービスの初期化
    ttsService = TtsService();
    locationService = LocationService();

    // Init text to speech
    _initTts();

    // Screen lock
    WakelockPlus.enable();

    // コンパスイベントのリスニング開始
    _compass = FlutterCompass.events?.listen(_changeHeading);

    // WebSocket接続
    _connectWs();

    // 定期処理の開始
    _initIsolate();
  }

  @override
  void dispose() {
    ttsService.pause();
    _compass!.cancel();
    _channel.sink.close(status.goingAway);
    WakelockPlus.disable();
    super.dispose();
  }

  _initTts() async {
    await ttsService.initialize(widget.ttsSpeed);
  }

  _initIsolate() async {
    _announceIsolate((widget.ttsDuration * 1000).toInt());
    _sendLocationIsolate(AppConstants.locationUpdateInterval);
    _sendBatteryIsolate(AppConstants.batteryUpdateInterval);
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
      await messageService.sendBattery();
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

    // WebSocketメッセージサービスの初期化
    messageService = WsMessageService(_channel);

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
    if (jwt != null) {
      messageService.sendAuth(jwt, widget.userId);
    } else {
      debugPrint('JWT token is null');
    }
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
        oldMarkNo = AppConstants.markNum;
      }
      messageService.sendPassed(oldMarkNo, _nextMarkNo);

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

    if (msg.markNum == AppConstants.markNum) {
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

  _sendLocation() async {
    await _getPosition();
    if (_started) {
      _checkPassed();
    }

    messageService.sendLocation(_lat, _lng, _accuracy, _heading, widget.headingFix);
  }

  _getPosition() async {
    geo.Position? pos = await locationService.getCurrentPosition();

    if (pos == null || !mounted) {
      return;
    }

    setState(() {
      _lat = pos.latitude;
      _lng = pos.longitude;
      _accuracy = pos.accuracy;
    });
  }

  _checkPassed() {
    if (_lat == 0.0 && _lng == 0.0 || _marks.isEmpty || _nextMarkNo > _marks.length) {
      return;
    }

    double diff = locationService.calculateDistance(
      _lat,
      _lng,
      _marks[_nextMarkNo - 1].position!.lat!,
      _marks[_nextMarkNo - 1].position!.lng!,
    );

    setState(() {
      _routeDistance = diff;
    });

    if (diff > widget.reachJudgeRadius) {
      return;
    }

    // Passed mark
    _onPassed();
  }

  _onPassed() {
    int oldMarkNo = _nextMarkNo;
    int nextMarkNo = oldMarkNo % AppConstants.markNum + 1;

    setState(() {
      // _lastPassedTime = DateTime.now();
      _nextMarkNo = nextMarkNo;
    });

    messageService.sendPassed(oldMarkNo, nextMarkNo);
    _passedAnnounce(oldMarkNo);
  }

  _changeHeading(CompassEvent evt) {
    double heading = evt.heading ?? 0.0;

    // Correct magnetic declination
    heading = correctHeading(heading, widget.headingFix);

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
    if (!_started || _marks.isEmpty || _nextMarkNo > _marks.length) {
      return 0;
    }

    return calculateCompassDegree(
      heading,
      _lat,
      _lng,
      _marks[_nextMarkNo - 1].position!.lat!,
      _marks[_nextMarkNo - 1].position!.lng!
    );
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
    if (_routeDistance >= AppConstants.maxDistance) {
      text = '向き、距離、不明';
    }

    await ttsService.speak(text);
  }

  _passedAnnounce(int markNo) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _enabledPeriodicAnnounce = false;
    });

    await ttsService.speakMultiple('${markNames[markNo]![1]}に到達', widget.reachNoticeNum);

    setState(() {
      _enabledPeriodicAnnounce = true;
    });
  }

  _forcePassed(int markNo) {
    int oldMarkNo = _nextMarkNo;
    int nextMarkNo = markNo % AppConstants.markNum + 1;

    messageService.sendPassed(oldMarkNo, nextMarkNo);

    setState(() {
      _nextMarkNo = nextMarkNo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop) {
          isPopDialog(context);
        }
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
                  maxDistance: AppConstants.maxDistance,
                  forcePassed: _forcePassed,
                  onPassed: _onPassed,
                  markNameType: widget.markNameType
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
