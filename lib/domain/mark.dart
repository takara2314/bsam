import 'package:flutter/material.dart';

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

MarkLabel getMarkLabel(int wantMarkCounts, int markNo) {
  if (
    !markLabels.containsKey(wantMarkCounts)
    || markNo < 1
    || markNo > markLabels[wantMarkCounts]!.length
  ) {
    throw ArgumentError('Invalid wantMarkCounts or markNo.');
  }

  return markLabels[wantMarkCounts]![markNo - 1];
}
