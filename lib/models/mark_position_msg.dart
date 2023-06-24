import 'package:bsam/models/mark.dart';

class MarkPositionMsg {
  int? markNum;
  List<Mark>? marks;

  MarkPositionMsg({
    this.markNum,
    this.marks
  });

  MarkPositionMsg.fromJson(Map<String, dynamic> json) {
    markNum = json['mark_num'];

    if (json['marks'] != null) {
      marks = <Mark>[];
      json['marks'].forEach((v) {
        marks!.add(Mark.fromJson(v));
      });
    }
  }
}
