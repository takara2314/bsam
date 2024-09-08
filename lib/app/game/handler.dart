import 'package:flutter/material.dart';
import 'dart:convert';

const handlerTypeConnectResult = 'connect_result';
const handlerTypeAuthResult = 'auth_result';
const handlerTypeMarkGeolocations = 'mark_geolocations';
const handlerTypeManageRaceStatus = 'manage_race_status';
const handlerTypeManageNextMark = 'manage_next_mark';

enum HandlerType {
  connectResult,
  authResult,
  markGeolocations,
  manageRaceStatus,
  manageNextMark,
}

class GameHandler {
  final Map<HandlerType, Function> _handlers = {};

  void handlePayload(dynamic payload) {
    final msg = json.decode(payload);

    final handlerType = _getHandlerType(msg['type']);
    if (handlerType != null) {
      final handler = _handlers[handlerType];
      if (handler != null) {
        // メッセージタイプに応じてパースし、対応するハンドラを呼び出す
        final parsed = _parseMessage(handlerType, msg);
        handler(parsed);
      } else {
        debugPrint('Handler not set for type: ${msg['type']}');
      }
    } else {
      debugPrint('Unknown message type: ${msg['type']}');
    }
  }

  void setConnectResultHandler(
    void Function(ConnectResultHandlerMessage) handler
  ) {
    _handlers[HandlerType.connectResult] = handler;
  }

  void setAuthResultHandler(
    void Function(AuthResultHandlerMessage) handler
  ) {
    _handlers[HandlerType.authResult] = handler;
  }

  void setMarkGeolocationsHandler(
    void Function(MarkGeolocationsHandlerMessage) handler
  ) {
    _handlers[HandlerType.markGeolocations] = handler;
  }

  void setManageRaceStatusHandler(
    void Function(ManageRaceStatusHandlerMessage) handler
  ) {
    _handlers[HandlerType.manageRaceStatus] = handler;
  }

  void setManageNextMarkHandler(
    void Function(ManageNextMarkHandlerMessage) handler
  ) {
    _handlers[HandlerType.manageNextMark] = handler;
  }

  HandlerType? _getHandlerType(String type) {
    switch (type) {
      case handlerTypeConnectResult:
        return HandlerType.connectResult;
      case handlerTypeAuthResult:
        return HandlerType.authResult;
      case handlerTypeMarkGeolocations:
        return HandlerType.markGeolocations;
      case handlerTypeManageRaceStatus:
        return HandlerType.manageRaceStatus;
      case handlerTypeManageNextMark:
        return HandlerType.manageNextMark;
      default:
        return null;
    }
  }

  dynamic _parseMessage(HandlerType type, Map<String, dynamic> msg) {
    switch (type) {
      case HandlerType.connectResult:
        return ConnectResultHandlerMessage.fromJson(msg);
      case HandlerType.authResult:
        return AuthResultHandlerMessage.fromJson(msg);
      case HandlerType.markGeolocations:
        return MarkGeolocationsHandlerMessage.fromJson(msg);
      case HandlerType.manageRaceStatus:
        return ManageRaceStatusHandlerMessage.fromJson(msg);
      case HandlerType.manageNextMark:
        return ManageNextMarkHandlerMessage.fromJson(msg);
    }
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
  final List<MarkGeolocationsMarkHandlerMessage> marks;

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
          .map((e) => MarkGeolocationsMarkHandlerMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MarkGeolocationsMarkHandlerMessage {
  final int markNo;
  final bool stored;
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final DateTime recordedAt;

  MarkGeolocationsMarkHandlerMessage({
    required this.markNo,
    required this.stored,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.recordedAt,
  });

  factory MarkGeolocationsMarkHandlerMessage.fromJson(Map<String, dynamic> json) {
    return MarkGeolocationsMarkHandlerMessage(
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
