import 'dart:async';

import 'package:bsam/app/game/engine.dart';
import 'package:bsam/app/game/state.dart';
import 'package:bsam/domain/mark.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// グローバルな状態管理のためのProviders
final associationIdProvider = StateProvider<String>((ref) => '');
final deviceIdProvider = StateProvider<String>((ref) => '');
final wantMarkCountsProvider = StateProvider<int>((ref) => 0);

// ゲームクライアントの状態を管理するProvider
final gameClientProvider = StateNotifierProvider.autoDispose<GameClientNotifier, GameClientState>((ref) {
  return GameClientNotifier(ref);
});

// ゲームクライアントの状態を管理するNotifier
class GameClientNotifier extends StateNotifier<GameClientState> {
  final StateNotifierProviderRef<GameClientNotifier, GameClientState> _ref;

  late final GameEngine engine;

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
    engine = GameEngine(_ref, this);
  }

  // 公開メソッド
  void connect() => engine.ws.connect();
  void disconnect() => engine.ws.disconnect();
  void registerGeolocation(GeolocationState geolocation) => engine.registerGeolocation(geolocation);
  void registerCallbackOnPassedMark(Future<void> Function(int) callback) => engine.registerCallbackOnPassedMark(callback);

  // ステートのgetterとsetter
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
  double? get distanceToNextMarkMeter => state.distanceToNextMarkMeter;

  void setCompassDegreeAndDistanceToNextMark(
    double? compassDegree,
    double? distanceToNextMarkMeter
  ) {
    state = state.copyWithNullableCompassDegreeAndDistanceToNextMarkMeter(
      compassDegree: compassDegree,
      distanceToNextMarkMeter: distanceToNextMarkMeter
    );
  }
}
