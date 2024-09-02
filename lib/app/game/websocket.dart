import 'package:bsam/app/game/game.dart';
import 'package:bsam/app/game/handler.dart';
import 'package:bsam/main.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

const pingInterval = Duration(seconds: 1);

class GameWebSocket {
  final Game game;
  final GameHandler handler;

  late IOWebSocketChannel conn;
  bool connected = false;
  bool _allowReconnect = true;

  GameWebSocket(this.game, this.handler);

  void connect(String associationId) {
    final url = Uri.parse(
      '$gameServerBaseUrlWs/$associationId'
    );

    conn = IOWebSocketChannel.connect(
      url,
      pingInterval: pingInterval
    );

    conn.stream.listen(
      (dynamic payload) {
        if (!connected) {
          connected = true;
          game.tryAuth();
        }

        handler.handlePayload(payload);
      },
      onDone: () {
        connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect...');
          connect(associationId);
        }
      },
      onError: (error) {
        connected = false;
        if (_allowReconnect) {
          debugPrint('reconnect... (with error: $error)');
          connect(associationId);
        }
      }
    );
  }

  void disconnect() {
    _allowReconnect = false;
    conn.sink.close(status.normalClosure);
  }

  bool send(String payload) {
    if (!connected) {
      return false;
    }
    conn.sink.add(payload);
    return true;
  }
}
