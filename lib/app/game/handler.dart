import 'package:flutter/material.dart';
import 'dart:convert';

const handlerTypeConnectResult = 'connect_result';
const handlerTypeAuthResult = 'auth_result';
const handlerTypeMarkGeolocations = 'mark_geolocations';
const handlerTypeManageRaceStatus = 'manage_race_status';
const handlerTypeManageNextMark = 'manage_next_mark';

class GameHandler {
  bool authed = false;
  bool started = false;
  List<MarkGeolocation> marks = [];

  void handlePayload(dynamic payload) {
    final msg = json.decode(payload);

    debugPrint(msg.toString());

    switch (msg['type']) {
      case handlerTypeConnectResult:
        final parsed = ConnectResultHandlerMessage.fromJson(msg);
        _handleConnectResult(parsed);
        break;

      case handlerTypeAuthResult:
        final parsed = AuthResultHandlerMessage.fromJson(msg);
        _handleAuthResult(parsed);
        break;

      case handlerTypeMarkGeolocations:
        final parsed = MarkGeolocationsHandlerMessage.fromJson(msg);
        _handleMarkGeolocations(parsed);
        break;

      case handlerTypeManageRaceStatus:
        final parsed = ManageRaceStatusHandlerMessage.fromJson(msg);
        _handleManageRaceStatus(parsed);
        break;

      case handlerTypeManageNextMark:
        final parsed = ManageNextMarkHandlerMessage.fromJson(msg);
        _handleManageNextMark(parsed);
        break;

      default:
        debugPrint(
          'Unknown message type: ${msg['type']}'
        );
    }
  }

  void _handleConnectResult(ConnectResultHandlerMessage msg) {}

  void _handleAuthResult(AuthResultHandlerMessage msg) {
    authed = msg.authed;
  }

  void _handleMarkGeolocations(MarkGeolocationsHandlerMessage msg) {
    marks = msg.marks;
  }

  void _handleManageRaceStatus(ManageRaceStatusHandlerMessage msg) {
    started = msg.started;
  }

  void _handleManageNextMark(ManageNextMarkHandlerMessage msg) {}
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
