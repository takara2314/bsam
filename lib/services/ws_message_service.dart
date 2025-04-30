import 'dart:convert';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// WebSocketメッセージサービス
class WsMessageService {
  final WebSocketChannel channel;
  final Battery _battery = Battery();
  bool _isClosed = false;

  WsMessageService(this.channel);

  /// WebSocketの状態を確認
  bool get isClosed => _isClosed;

  /// WebSocketを閉じる
  void close() {
    _isClosed = true;
  }

  /// 認証メッセージを送信
  void sendAuth(String jwt, String userId) {
    _sendMessage({
      'type': 'auth',
      'token': jwt,
      'user_id': userId,
      'role': 'athlete'
    });
  }

  /// 位置情報を送信
  void sendLocation(double lat, double lng, double accuracy, double heading, double headingFix) {
    _sendMessage({
      'type': 'location',
      'latitude': lat,
      'longitude': lng,
      'accuracy': accuracy,
      'heading': heading,
      'heading_fixing': headingFix
    });
  }

  /// バッテリー情報を送信
  Future<void> sendBattery() async {
    final level = await _getBatteryLevel();
    _sendMessage({
      'type': 'battery',
      'level': level
    });
  }

  /// マークを通過したことを送信
  void sendPassed(int passedMarkNo, int nextMarkNo) {
    _sendMessage({
      'type': 'passed',
      'passed_mark_no': passedMarkNo,
      'next_mark_no': nextMarkNo
    });
  }

  /// メッセージ送信の共通処理
  void _sendMessage(Map<String, dynamic> data) {
    if (_isClosed) {
      debugPrint('Attempted to send message on closed WebSocket: ${data['type']}');
      return;
    }

    try {
      channel.sink.add(json.encode(data));
    } catch (e) {
      debugPrint('WS message error: ${e.toString()}');
      // エラーが発生した場合はWebSocketが閉じられたと見なす
      _isClosed = true;
    }
  }

  /// バッテリーレベルを取得
  Future<int> _getBatteryLevel() async {
    try {
      return await _battery.batteryLevel;
    } catch (e) {
      debugPrint('Battery error: ${e.toString()}');
      return -1;
    }
  }
}
