import 'package:bsam/app/game/game.dart';
import 'package:bsam/app/game/handler.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GameNavigate extends ChangeNotifier {
  int nextMarkNo = 1;

  final Game game;

  GameNavigate(this.game);

  MarkLabel get nextMarkLabel {
    final labels = markLabels[game.wantMarkCounts]!;
    return labels[nextMarkNo - 1];
  }

  MarkGeolocation? get nextMark {
    if (game.marks.isEmpty) {
      return null;
    }
    return game.marks[nextMarkNo - 1];
  }

  // TODO: wantMarkCounts が1のときの処理も実装する
  Future<void> passMark(int passedMarkNo) async {
    // マークを通過したことをサーバーに通知

    // 次のマークを設定
    nextMarkNo = passedMarkNo + 1;
    if (nextMarkNo > game.wantMarkCounts) {
      nextMarkNo = 1;
    }
  }

  double calcNextMarkDistanceMeter(double lat, double lng) {
    if (nextMark == null) {
      return 0;
    }
    return Geolocator.distanceBetween(
      lat,
      lng,
      nextMark!.latitude,
      nextMark!.longitude
    );
  }

  double calcNextMarkCompassDeg(double lat, double lng, double heading) {
    if (nextMark == null) {
      return 0;
    }

    // 現在位置から次のマークまでの方位角を計算
    double bearingDeg = Geolocator.bearingBetween(
      lat,
      lng,
      nextMark!.latitude,
      nextMark!.longitude
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
}

class MarkLabel {
  final int no;
  final String name;
  final String nameKatakana;

  MarkLabel(
    this.no,
    this.name,
    this.nameKatakana,
  );
}

final markLabels = Map<int, List<MarkLabel>>.from({
  1: [
    MarkLabel(1, '', ''),
  ],
  2: [
    MarkLabel(1, '上', 'カミ'),
    MarkLabel(2, '下', 'シモ'),
  ],
  3: [
    MarkLabel(1, '上', 'カミ'),
    MarkLabel(2, 'サイド', 'サイド'),
    MarkLabel(3, '下', 'シモ'),
  ],
  4: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
  ],
  5: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
  ],
  6: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
  ],
  7: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
  ],
  8: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
  ],
  9: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
    MarkLabel(9, '9', 'キュウ'),
  ],
  10: [
    MarkLabel(1, '1', 'イチ'),
    MarkLabel(2, '2', 'ニ'),
    MarkLabel(3, '3', 'サン'),
    MarkLabel(4, '4', 'ヨン'),
    MarkLabel(5, '5', 'ゴ'),
    MarkLabel(6, '6', 'ロク'),
    MarkLabel(7, '7', 'ナナ'),
    MarkLabel(8, '8', 'ハチ'),
    MarkLabel(9, '9', 'キュウ'),
    MarkLabel(10, '10', 'ジュウ'),
  ]
});
