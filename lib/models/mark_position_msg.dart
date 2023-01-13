import 'package:bsam/models/position.dart';

class MarkPositionMsg {
  int? markNum;
  List<Position>? positions;

  MarkPositionMsg({this.markNum, this.positions});

  MarkPositionMsg.fromJson(Map<String, dynamic> json) {
    markNum = json['mark_num'];

    if (json['positions'] != null) {
      positions = <Position>[];
      json['positions'].forEach((v) {
        positions!.add(Position.fromJson(v));
      });
    }
  }
}
