import 'package:bsam/app/game/game.dart';

class GameNavigate {
  int nextMarkNo = 1;

  final Game game;

  GameNavigate(this.game);

  MarkLabel get nextMarkLabel {
    final labels = markLabels[game.wantMarkCounts]!;
    return labels[nextMarkNo - 1];
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
    MarkLabel(1, 'マーク', 'マーク'),
  ],
  2: [
    MarkLabel(1, '上マーク', 'カミマーク'),
    MarkLabel(2, '下マーク', 'シモマーク'),
  ],
  3: [
    MarkLabel(1, '上マーク', 'カミマーク'),
    MarkLabel(2, 'サイドマーク', 'サイドマーク'),
    MarkLabel(3, '下マーク', 'シモマーク'),
  ],
  4: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
  ],
  5: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
  ],
  6: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
    MarkLabel(6, '6マーク', 'ロクマーク'),
  ],
  7: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
    MarkLabel(6, '6マーク', 'ロクマーク'),
    MarkLabel(7, '7マーク', 'ナナマーク'),
  ],
  8: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
    MarkLabel(6, '6マーク', 'ロクマーク'),
    MarkLabel(7, '7マーク', 'ナナマーク'),
    MarkLabel(8, '8マーク', 'ハチマーク'),
  ],
  9: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
    MarkLabel(6, '6マーク', 'ロクマーク'),
    MarkLabel(7, '7マーク', 'ナナマーク'),
    MarkLabel(8, '8マーク', 'ハチマーク'),
    MarkLabel(9, '9マーク', 'キュウマーク'),
  ],
  10: [
    MarkLabel(1, '1マーク', 'イチマーク'),
    MarkLabel(2, '2マーク', 'ニマーク'),
    MarkLabel(3, '3マーク', 'サンマーク'),
    MarkLabel(4, '4マーク', 'ヨンマーク'),
    MarkLabel(5, '5マーク', 'ゴマーク'),
    MarkLabel(6, '6マーク', 'ロクマーク'),
    MarkLabel(7, '7マーク', 'ナナマーク'),
    MarkLabel(8, '8マーク', 'ハチマーク'),
    MarkLabel(9, '9マーク', 'キュウマーク'),
    MarkLabel(10, '10マーク', 'ジュウマーク'),
  ]
});
