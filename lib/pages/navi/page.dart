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
    required this.ttsLanguage,
    required this.ttsVolume,
    required this.ttsPitch,
    required this.headingFix,
    required this.isAnnounceNeighbors,
  });

  final String assocId;
  final String userId;
  final String ttsLanguage;
  final double ttsVolume;
  final double ttsPitch;
  final double headingFix;
  final bool isAnnounceNeighbors;

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
  bool _disposed = false;

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

  // 設定値をproviderから取得するためのgetter
  double get ttsSpeed => ref.watch(ttsSpeedProvider);
  double get ttsDuration => ref.watch(ttsDurationProvider);
  int get reachJudgeRadius => ref.watch(reachJudgeRadiusProvider);
  int get reachNoticeNum => ref.watch(reachNoticeNumProvider);
  int get markNameType => ref.watch(markNameTypeProvider);

  @override
  void initState() {
    super.initState();

    // 設定値がproviderから正しく取得できているか確認
    debugPrint('Navi設定値(provider): ttsSpeed=${ttsSpeed}, ttsDuration=${ttsDuration}, reachJudgeRadius=${reachJudgeRadius}, reachNoticeNum=${reachNoticeNum}, markNameType=${markNameType}');

    // Mark names initialization based on type
    markNames = markNameType == 0
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
    _disposed = true;
    // 各種リソースの解放
    ttsService.pause();
    if (_compass != null) {
      _compass!.cancel();
      _compass = null;
    }

    // WebSocketメッセージサービスを閉じる
    try {
      messageService.close();
    } catch (e) {
      // messageServiceがまだ初期化されていない可能性がある
      debugPrint('Error closing message service: $e');
    }

    // WebSocketの接続を適切に閉じる
    try {
      _channel.sink.close(status.normalClosure);
    } catch (e) {
      debugPrint('Error closing WebSocket: $e');
    }

    WakelockPlus.disable();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 設定が変更されたかチェック
    final currentMarkNameType = ref.read(markNameTypeProvider);

    // マーク名称タイプが変更された場合は再設定
    if (markNames.isEmpty || (currentMarkNameType == 0 && markNames != AppConstants.standardMarkNames) ||
        (currentMarkNameType == 1 && markNames != AppConstants.numericMarkNames)) {
      setState(() {
        markNames = currentMarkNameType == 0
            ? AppConstants.standardMarkNames
            : AppConstants.numericMarkNames;
      });
      debugPrint('マーク名称が変更されました: タイプ=$currentMarkNameType');
    }
  }

  _initTts() async {
    await ttsService.initialize(
      widget.ttsLanguage,
      ttsSpeed,
      widget.ttsVolume,
      widget.ttsPitch
    );
  }

  _initIsolate() async {
    // ttsDuration が変更されたときに再初期化するために、前のタイマーを覚えておく
    await _startAnnounceIsolate();
    _sendLocationIsolate(AppConstants.locationUpdateInterval);
    _sendBatteryIsolate(AppConstants.batteryUpdateInterval);
  }

  // ttsDurationの変更を監視して、アナウンスの間隔を調整するメソッド
  Future<void> _startAnnounceIsolate() async {
    _announceIsolate((ttsDuration * 1000).toInt());
  }

  _announceIsolate(int interval) async {
    while (true) {
      if (_disposed) {
        return;
      }
      await _announce();
      await Future.delayed(Duration(milliseconds: interval));
    }
  }

  _sendLocationIsolate(int interval) async {
    while (true) {
      if (_disposed) {
        return;
      }
      await _sendLocation();
      await Future.delayed(Duration(milliseconds: interval));
    }
  }

  _sendBatteryIsolate(int interval) async {
    while (true) {
      if (_disposed) {
        return;
      }
      await messageService.sendBattery();
      await Future.delayed(Duration(milliseconds: interval));
    }
  }

  _connectWs() {
    if (_disposed) {
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

    _channel.stream.listen(
      _readWsMsg,
      onDone: () {
        debugPrint('WebSocket connection closed');
        // disposeされていない場合のみ再接続を試みる
        if (!_disposed) {
          debugPrint('Attempting to reconnect...');
          // setState()を使用する前に、ウィジェットがまだマウントされているか確認
          if (mounted) {
            setState(() {
              _reconnected = true;
            });
            _connectWs();
          }
        }
      },
      onError: (error) {
        debugPrint('WebSocket error: $error');
        // エラー発生時も同様に、disposeされていない場合のみ再接続
        if (!_disposed && mounted) {
          Future.delayed(const Duration(seconds: 3), _connectWs);
        }
      },
      cancelOnError: false
    );

    final jwt = ref.read(jwtProvider);
    if (jwt != null) {
      messageService.sendAuth(jwt, widget.userId);
    } else {
      debugPrint('JWT token is null');
    }
  }

  _readWsMsg(dynamic msg) {
    if (_disposed) return;

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
    if (_disposed || !mounted) return;

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
    if (_disposed || !mounted) return;

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
    if (_disposed || !mounted) return;

    if (!_started || !widget.isAnnounceNeighbors) {
      return;
    }

    // setState(() {
    //   _nearSailNum = msg['neighbors'].length;
    // });
  }

  _receiveStartRace(dynamic msg) {
    if (_disposed || !mounted) return;

    // race status
    setState(() {
      _started = msg['started'];
    });
  }

  _receiveSetMarkNo(dynamic msg) {
    if (_disposed || !mounted) return;

    setState(() {
      _nextMarkNo = msg['next_mark_no'];
    });
  }

  _sendLocation() async {
    if (_disposed) return;

    await _getPosition();
    if (_started) {
      _checkPassed();
    }

    messageService.sendLocation(_lat, _lng, _accuracy, _heading, widget.headingFix);
  }

  _getPosition() async {
    if (_disposed) return;

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
    if (_disposed || _lat == 0.0 && _lng == 0.0 || _marks.isEmpty || _nextMarkNo > _marks.length) {
      return;
    }

    double diff = locationService.calculateDistance(
      _lat,
      _lng,
      _marks[_nextMarkNo - 1].position!.lat!,
      _marks[_nextMarkNo - 1].position!.lng!,
    );

    if (!mounted) return;

    setState(() {
      _routeDistance = diff;
    });

    if (diff > reachJudgeRadius) {
      return;
    }

    // Passed mark
    _onPassed();
  }

  _onPassed() {
    if (_disposed || !mounted) return;

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
    if (_disposed || !mounted) return;

    double heading = evt.heading ?? 0.0;

    // Correct magnetic declination
    heading = correctHeading(heading, widget.headingFix);

    setState(() {
      _heading = heading;
    });

    _changeCompassDeg(heading);
  }

  _changeCompassDeg(double heading) {
    if (_disposed || !mounted || !_started) {
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
    if (_disposed) return;

    // If not started, skip tts
    if (!_started) {
      return;
    }

    // If stopped periodic tts, skip tts
    if (!_enabledPeriodicAnnounce) {
      return;
    }

    String text;
    if (!_isDistanceValid(_routeDistance)) {
      text = '向き、距離、不明';
    } else {
      text = '${markNames[_nextMarkNo]![1]}、${getDegName(_compassDeg)}、${_routeDistance.toInt()}';
    }

    await ttsService.speak(text);
  }

  _isDistanceValid(double distance) {
    return !distance.isInfinite && !distance.isNaN && distance < AppConstants.maxDistance;
  }

  _passedAnnounce(int markNo) async {
    if (_disposed || !mounted) return;

    setState(() {
      _enabledPeriodicAnnounce = false;
    });

    await ttsService.speakMultiple('${markNames[markNo]![1]}に到達', reachNoticeNum);

    if (!mounted) return;

    setState(() {
      _enabledPeriodicAnnounce = true;
    });
  }

  _forcePassed(int markNo) {
    if (_disposed || !mounted) return;

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
                  markNameType: markNameType
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
