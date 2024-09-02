import 'package:bsam/app/game/websocket.dart';
import 'dart:convert';

const actionTypeAuth = 'auth';
const actionTypePostGeolocation = 'post_geolocation';

class GameAction {
  final GameWebSocket ws;

  GameAction(this.ws);

  bool sendAuthAction(AuthActionMessage msg) {
    return ws.send(msg.toJsonString());
  }

  bool sendPostGeolocationAction(PostGeolocationActionMessage msg) {
    return ws.send(msg.toJsonString());
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
