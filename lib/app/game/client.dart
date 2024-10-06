import 'dart:async';
import 'dart:convert';

import 'package:bsam/domain/judge.dart';
import 'package:bsam/main.dart';
import 'package:bsam/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

const pingInterval = Duration(seconds: 1);

const handlerTypeConnectResult = 'connect_result';
const handlerTypeAuthResult = 'auth_result';
const handlerTypeMarkGeolocations = 'mark_geolocations';
const handlerTypeManageRaceStatus = 'manage_race_status';
const handlerTypeManageNextMark = 'manage_next_mark';

const actionTypeAuth = 'auth';
const actionTypePostGeolocation = 'post_geolocation';

final associationIdProvider = StateProvider<String>((ref) => '');
final deviceIdProvider = StateProvider<String>((ref) => '');
final wantMarkCountsProvider = StateProvider<int>((ref) => 0);

const positingGeolocationInterval = Duration(seconds: 1);

void useGeolocationRegister(
  BuildContext context,
  GameClientNotifier client,
  GeolocationState geolocation,
) {
  useEffect(() {
    Future.microtask(() {
      if (!client.connected || !geolocation.fetched || !context.mounted) {
        return;
      }
      client.registerGeolocation(geolocation);
    });

    return null;
  }, [geolocation]);
}

final gameClientProvider = StateNotifierProvider.autoDispose<GameClientNotifier, GameClientState>((ref) {
  return GameClientNotifier(ref);
});

class GameClientNotifier extends StateNotifier<GameClientState> {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;

  late final GameEngine _engine;
  // late final GameNavigator _navigator;

  GameClientNotifier(this._ref) : super(
    const GameClientState(
      connected: false,
      authed: false,
      started: false,
      marks: null,
      nextMarkNo: 1,
      geolocation: null,
      compassDegree: null,
      distanceToNextMarkMeter: null,
    )
  ) {
    _engine = GameEngine(_ref, this);
    // _navigator = GameNavigator(this);
  }

  void connect() => _engine._ws._connect();
  void disconnect() => _engine._ws._disconnect();
  void registerGeolocation(GeolocationState geolocation) => _engine._registerGeolocation(geolocation);
  void registerCallbackOnPassedMark(Future<void> Function(int) callback) => _engine._registerCallbackOnPassedMark(callback);

  bool get connected => state.connected;
  set connected(bool value) {
    state = state.copyWith(connected: value);
  }

  bool get authed => state.authed;
  set authed(bool value) {
    state = state.copyWith(authed: value);
  }

  bool get started => state.started;
  set started(bool value) {
    state = state.copyWith(started: value);
  }

  List<MarkGeolocation>? get marks => state.marks;
  set marks(List<MarkGeolocation>? value) {
    state = state.copyWith(marks: value);
  }

  int get nextMarkNo => state.nextMarkNo;
  set nextMarkNo(int value) {
    state = state.copyWith(nextMarkNo: value);
  }

  MarkGeolocation? get nextMark => state.nextMark;

  GeolocationState? get geolocation => state.geolocation;
  set geolocation(GeolocationState? value) {
    state = state.copyWith(geolocation: value);
  }

  double? get compassDegree => state.compassDegree;
  set compassDegree(double? value) {
    state = state.copyWith(compassDegree: value);
  }

  double? get distanceToNextMarkMeter => state.distanceToNextMarkMeter;
  set distanceToNextMarkMeter(double? value) {
    state = state.copyWith(distanceToNextMarkMeter: value);
  }
}

@immutable
class GameClientState {
  final bool connected;
  final bool authed;
  final bool started;
  final List<MarkGeolocation>? marks;
  final int nextMarkNo;
  final GeolocationState? geolocation;
  final double? compassDegree;
  final double? distanceToNextMarkMeter;

  const GameClientState({
    required this.connected,
    required this.authed,
    required this.started,
    required this.marks,
    required this.nextMarkNo,
    required this.geolocation,
    required this.compassDegree,
    required this.distanceToNextMarkMeter,
  });

  GameClientState copyWith({
    bool? connected,
    bool? authed,
    bool? started,
    List<MarkGeolocation>? marks,
    int? nextMarkNo,
    GeolocationState? geolocation,
    double? compassDegree,
    double? distanceToNextMarkMeter,
  }) {
    return GameClientState(
      connected: connected ?? this.connected,
      authed: authed ?? this.authed,
      started: started ?? this.started,
      marks: marks ?? this.marks,
      nextMarkNo: nextMarkNo ?? this.nextMarkNo,
      geolocation: geolocation ?? this.geolocation,
      compassDegree: compassDegree ?? this.compassDegree,
      distanceToNextMarkMeter: distanceToNextMarkMeter ?? this.distanceToNextMarkMeter,
    );
  }

  MarkGeolocation? get nextMark => marks?[nextMarkNo - 1];
}

class GameEngine {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;
  final GameClientNotifier _client;

  late final GameWebSocket _ws;

  Future<void> Function(int)? _callbackOnPassedMark;
  Timer? _postingGeolocationTimer;

  GameEngine(this._ref, this._client) {
    _ws = GameWebSocket(_ref, _client);
  }

  void _handleConnected() {
    final token = _ref.read(tokenProvider);
    final deviceId = _ref.read(deviceIdProvider);
    final wantMarkCounts = _ref.read(wantMarkCountsProvider);

    _tryAuth(token, deviceId, wantMarkCounts);
  }

  void _handleDisconnected() {
    if (_postingGeolocationTimer != null) {
      _postingGeolocationTimer!.cancel();
    }
  }

  void _handleAuthed() {
    _startPostingGeolocation();
  }

  void _handleUnauthed() {}

  void _handleStarted() {}

  void _handleFinished() {}

  void _handleChangedGeolocation(GeolocationState geolocation) {
    _client.compassDegree = _calcNextMarkCompassDeg(
      geolocation.position!.latitude,
      geolocation.position!.longitude,
      geolocation.position!.heading
    );

    _client.distanceToNextMarkMeter = _calcNextMarkDistanceMeter(
      geolocation.position!.latitude,
      geolocation.position!.longitude
    );

    // マークを通過したかどうかを判定
    if (_judgePassedMark(_client.distanceToNextMarkMeter)) {
      _handlePassedMark(_client.nextMarkNo);
    }
  }

  // TODO: wantMarkCounts が1のときの処理も実装する
  Future<void> _handlePassedMark(int passedMarkNo) async {
    // 通過したことをアナウンスする
    if (_callbackOnPassedMark != null) {
      _callbackOnPassedMark!(passedMarkNo);
    }

    // 通過したことをサーバーに通知

    final wantMarkCounts = _ref.read(wantMarkCountsProvider);

    // 次のマークを設定
    _client.nextMarkNo = passedMarkNo + 1;
    if (_client.nextMarkNo > wantMarkCounts) {
      _client.nextMarkNo = 1;
    }
  }

  void _tryAuth(token, deviceId, wantMarkCounts) {
    _client._engine._ws._sender._sendAuthAction(AuthActionMessage(
      token: token,
      deviceId: deviceId,
      wantMarkCounts: wantMarkCounts
    ));
  }

  void _registerGeolocation(GeolocationState geolocation) {
    _client.geolocation = geolocation;
    _handleChangedGeolocation(geolocation);
  }

  void _registerCallbackOnPassedMark(Future<void> Function(int) callback) {
    _callbackOnPassedMark = callback;
  }

  void _startPostingGeolocation() {
    if (_postingGeolocationTimer != null) {
      return;
    }

    _postingGeolocationTimer = Timer.periodic(positingGeolocationInterval, (_) {
      if (_client.geolocation?.position == null) {
        return;
      }

      _client._engine._ws._sender._sendPostGeolocationAction(
        PostGeolocationActionMessage(
          latitude: _client.geolocation!.position!.latitude,
          longitude: _client.geolocation!.position!.longitude,
          altitudeMeter: _client.geolocation!.position!.altitude,
          accuracyMeter: _client.geolocation!.position!.accuracy,
          altitudeAccuracyMeter: _client.geolocation!.position!.altitudeAccuracy,
          heading: _client.geolocation!.position!.heading,
          speedMeterPerSec: _client.geolocation!.position!.speed,
          recordedAt: DateTime.now(),
        )
      );
    });
  }

  double? _calcNextMarkDistanceMeter(double lat, double lng) {
    if (_client.nextMark == null) {
      return null;
    }

    // ストアされていないマークは距離を計算しない
    if (!_client.nextMark!.stored) {
      return null;
    }

    return Geolocator.distanceBetween(
      lat,
      lng,
      _client.nextMark!.latitude,
      _client.nextMark!.longitude
    );
  }

  double? _calcNextMarkCompassDeg(double lat, double lng, double heading) {
    if (_client.nextMark == null) {
      return null;
    }

    // ストアされていないマークは距離を計算しない
    if (!_client.nextMark!.stored) {
      return null;
    }

    // 現在位置から次のマークまでの方位角を計算
    double bearingDeg = Geolocator.bearingBetween(
      lat,
      lng,
      _client.nextMark!.latitude,
      _client.nextMark!.longitude
    );

    // 現在の進行方向と目的地への方位角の差を計算
    double diff = bearingDeg - heading;

    // 差を-180度から180度の範囲に正規化
    if (diff > 180) {
      diff -= 360;
    } else if (diff < -180) {
      diff += 360;
    }

    // 正規化された差を返す（これがコンパスに表示される角度）
    return diff;
  }

  bool _judgePassedMark(double? distanceToNextMarkMeter) {
    if (distanceToNextMarkMeter == null) {
      return false;
    }

    return distanceToNextMarkMeter < passingDistanceMeter;
  }

  void _handleConnectResult(ConnectResultHandlerMessage msg) {}

  void _handleAuthResult(AuthResultHandlerMessage msg) {
    _client.authed = msg.authed;
    // 認証が成功したなら
    if (msg.authed) {
      _handleAuthed();
    } else {
      _handleUnauthed();
    }
  }

  void _handleMarkGeolocations(MarkGeolocationsHandlerMessage msg) {
    _client.marks = msg.marks;
  }

  void _handleManageRaceStatus(ManageRaceStatusHandlerMessage msg) {
    _client.started = msg.started;
    // レースがスタートしたなら
    if (msg.started) {
      _handleStarted();
    } else {
      _handleFinished();
    }
  }

  void _handleManageNextMark(ManageNextMarkHandlerMessage msg) {}
}

class GameWebSocket {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;
  final GameClientNotifier _client;

  final GameWebSocketReceiver _receiver;
  final GameWebSocketSender _sender;

  late IOWebSocketChannel conn;
  bool _allowReconnect = true;

  GameWebSocket(this._ref, this._client)
    : _receiver = GameWebSocketReceiver(_client),
      _sender = GameWebSocketSender(_client);

  void _connect() {
    final associationId = _ref.read(associationIdProvider);

    final url = Uri.parse(
      '$gameServerBaseUrlWs/$associationId'
    );

    conn = IOWebSocketChannel.connect(
      url,
      pingInterval: pingInterval
    );

    conn.stream.listen(
      (dynamic payload) {
        // 初めてのコネクション設立なら
        if (!_client.connected) {
          _client.connected = true;
          _client._engine._handleConnected();
        }
        _receiver._handlePayload(payload);
      },
      onDone: () {
        _client.connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect...');
          _connect();
        }
      },
      onError: (error) {
        _client.connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect... (with error: $error)');
          _connect();
        }
      }
    );
  }

  void _disconnect() {
    _allowReconnect = false;
    _client._engine._handleDisconnected();
    conn.sink.close(status.normalClosure);
  }

  bool _send(String payload) {
    if (!_client.connected) {
      return false;
    }
    conn.sink.add(payload);
    return true;
  }
}

class GameWebSocketReceiver {
  final GameClientNotifier _client;

  GameWebSocketReceiver(this._client);

  void _handlePayload(dynamic payload) {
    final msg = json.decode(payload);

    switch (msg['type']) {
      case handlerTypeConnectResult:
        final parsed = ConnectResultHandlerMessage.fromJson(msg);
        _client._engine._handleConnectResult(parsed);
        break;

      case handlerTypeAuthResult:
        final parsed = AuthResultHandlerMessage.fromJson(msg);
        _client._engine._handleAuthResult(parsed);
        break;

      case handlerTypeMarkGeolocations:
        final parsed = MarkGeolocationsHandlerMessage.fromJson(msg);
        _client._engine._handleMarkGeolocations(parsed);
        break;

      case handlerTypeManageRaceStatus:
        final parsed = ManageRaceStatusHandlerMessage.fromJson(msg);
        _client._engine._handleManageRaceStatus(parsed);
        break;

      case handlerTypeManageNextMark:
        final parsed = ManageNextMarkHandlerMessage.fromJson(msg);
        _client._engine._handleManageNextMark(parsed);
        break;

      default:
        debugPrint('Unknown message type: ${msg['type']}');
    }
  }
}

class GameWebSocketSender {
  final GameClientNotifier _client;

  GameWebSocketSender(this._client);

  bool _sendAuthAction(AuthActionMessage msg) {
    return _client._engine._ws._send(msg.toJsonString());
  }

  bool _sendPostGeolocationAction(PostGeolocationActionMessage msg) {
    return _client._engine._ws._send(msg.toJsonString());
  }
}

class MarkGeolocation {
  final int markNo;
  final bool stored;
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final DateTime recordedAt;

  MarkGeolocation({
    required this.markNo,
    required this.stored,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.recordedAt,
  });

  factory MarkGeolocation.fromJson(Map<String, dynamic> json) {
    return MarkGeolocation(
      markNo: json['mark_no'] as int,
      stored: json['stored'] as bool,
      latitude: json['latitude'].toDouble() as double,
      longitude: json['longitude'].toDouble() as double,
      accuracyMeter: json['accuracy_meter'].toDouble() as double,
      heading: json['heading'].toDouble() as double,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }
}

class ConnectResultHandlerMessage {
  final String messageType;
  final bool ok;
  final String hubId;

  ConnectResultHandlerMessage({
    required this.messageType,
    required this.ok,
    required this.hubId,
  });

  factory ConnectResultHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ConnectResultHandlerMessage(
      messageType: json['type'] as String,
      ok: json['ok'] as bool,
      hubId: json['hub_id'] as String,
    );
  }
}

class AuthResultHandlerMessage {
  final String messageType;
  final bool ok;
  final String deviceId;
  final String role;
  final int markNo;
  final bool authed;
  final String message;

  AuthResultHandlerMessage({
    required this.messageType,
    required this.ok,
    required this.deviceId,
    required this.role,
    required this.markNo,
    required this.authed,
    required this.message,
  });

  factory AuthResultHandlerMessage.fromJson(Map<String, dynamic> json) {
    return AuthResultHandlerMessage(
      messageType: json['type'] as String,
      ok: json['ok'] as bool,
      deviceId: json['device_id'] as String,
      role: json['role'] as String,
      markNo: json['mark_no'] as int,
      authed: json['authed'] as bool,
      message: json['message'] as String,
    );
  }
}

class MarkGeolocationsHandlerMessage {
  final String messageType;
  final int markCounts;
  final List<MarkGeolocation> marks;

  MarkGeolocationsHandlerMessage({
    required this.messageType,
    required this.markCounts,
    required this.marks,
  });

  factory MarkGeolocationsHandlerMessage.fromJson(Map<String, dynamic> json) {
    return MarkGeolocationsHandlerMessage(
      messageType: json['type'] as String,
      markCounts: json['mark_counts'] as int,
      marks: (json['marks'] as List<dynamic>)
          .map((e) => MarkGeolocation.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManageRaceStatusHandlerMessage {
  final String messageType;
  final bool started;
  final DateTime startedAt;
  final DateTime finishedAt;

  ManageRaceStatusHandlerMessage({
    required this.messageType,
    required this.started,
    required this.startedAt,
    required this.finishedAt,
  });

  factory ManageRaceStatusHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ManageRaceStatusHandlerMessage(
      messageType: json['type'] as String,
      started: json['started'] as bool,
      startedAt: DateTime.parse(json['started_at'] as String),
      finishedAt: DateTime.parse(json['finished_at'] as String),
    );
  }
}

class ManageNextMarkHandlerMessage {
  final String messageType;
  final int nextMarkNo;

  ManageNextMarkHandlerMessage({
    required this.messageType,
    required this.nextMarkNo,
  });

  factory ManageNextMarkHandlerMessage.fromJson(Map<String, dynamic> json) {
    return ManageNextMarkHandlerMessage(
      messageType: json['type'] as String,
      nextMarkNo: json['next_mark_no'] as int,
    );
  }
}

class AuthActionMessage {
  final String type;
  final String token;
  final String deviceId;
  final int wantMarkCounts;

  AuthActionMessage({
    this.type = actionTypeAuth,
    required this.token,
    required this.deviceId,
    required this.wantMarkCounts,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'token': token,
    'device_id': deviceId,
    'want_mark_counts': wantMarkCounts,
  };

  String toJsonString() => jsonEncode(toJson());
}

class PostGeolocationActionMessage {
  final String type;
  final double latitude;
  final double longitude;
  final double altitudeMeter;
  final double accuracyMeter;
  final double altitudeAccuracyMeter;
  final double heading;
  final double speedMeterPerSec;
  final DateTime recordedAt;

  PostGeolocationActionMessage({
    this.type = actionTypePostGeolocation,
    required this.latitude,
    required this.longitude,
    required this.altitudeMeter,
    required this.accuracyMeter,
    required this.altitudeAccuracyMeter,
    required this.heading,
    required this.speedMeterPerSec,
    required this.recordedAt,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'latitude': latitude,
    'longitude': longitude,
    'altitude_meter': altitudeMeter,
    'accuracy_meter': accuracyMeter,
    'altitude_accuracy_meter': altitudeAccuracyMeter,
    'heading': heading,
    'speed_meter_per_sec': speedMeterPerSec,
    'recorded_at': recordedAt.toUtc().toIso8601String(),
  };

  String toJsonString() => jsonEncode(toJson());
}
