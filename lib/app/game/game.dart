import 'package:bsam/app/game/action.dart';
import 'package:bsam/app/game/handler.dart';
import 'package:bsam/app/game/navigate.dart';
import 'package:bsam/app/game/websocket.dart';

const pingInterval = Duration(seconds: 1);

class Game {
  late final GameWebSocket ws;
  late final GameAction action;
  late final GameNavigate navigate;
  final GameHandler handler = GameHandler();

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
    ws = GameWebSocket(this, handler);
    action = GameAction(ws);
    navigate = GameNavigate(this);
  }

  void connect() => ws.connect(associationId);
  void disconnect() => ws.disconnect();
  bool get connected => ws.connected;
  bool get authed => handler.authed;
  bool get started => handler.started;
  List<MarkGeolocation> get marks => handler.marks;

  void tryAuth() {
    action.sendAuthAction(AuthActionMessage(
      token: token,
      deviceId: deviceId,
      wantMarkCounts: wantMarkCounts
    ));
  }
}
