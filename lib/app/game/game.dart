import 'package:bsam/app/game/action.dart';
import 'package:bsam/app/game/handler.dart';
import 'package:bsam/app/game/websocket.dart';

const pingInterval = Duration(seconds: 1);

class Game {
  late final GameWebSocket ws;
  late final GameHandler handler;
  late final GameAction action;

  final String token;
  final String associationId;
  final String deviceId;
  final int wantMarkCounts;

  Game(
    this.token,
    this.associationId,
    this.deviceId,
    this.wantMarkCounts
  ) {
    handler = GameHandler();
    ws = GameWebSocket(this, handler);
    action = GameAction(ws);
  }

  void connect() => ws.connect(associationId);
  void disconnect() => ws.disconnect();
  get connected => ws.connected;

  void tryAuth() {
    action.sendAuthAction(AuthActionMessage(
      token: token,
      deviceId: deviceId,
      wantMarkCounts: wantMarkCounts
    ));
  }
}
