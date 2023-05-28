import 'package:bsam/models/position.dart';

class MarkPositionMsg {
  int? markNum;
  List<PositionWithId>? marks;

  MarkPositionMsg({
    this.markNum,
    this.marks
  });

  MarkPositionMsg.fromJson(Map<String, dynamic> json) {
    markNum = json['mark_num'];

    if (json['marks'] != null) {
      marks = <PositionWithId>[];
      json['marks'].forEach((v) {
        marks!.add(PositionWithId.fromJson(v));
      });
    }
  }
}
