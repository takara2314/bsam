class MarkPositionMsg {
  int? markNum;
  List<MarkPosition>? positions;

  MarkPositionMsg({this.markNum, this.positions});

  MarkPositionMsg.fromJson(Map<String, dynamic> json) {
    markNum = json['mark_num'];
    if (json['positions'] != null) {
      positions = <MarkPosition>[];
      json['positions'].forEach((v) {
        positions!.add(MarkPosition.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['mark_num'] = markNum;
    if (positions != null) {
      data['positions'] = positions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MarkPosition {
  double? lat;
  double? lng;

  MarkPosition({this.lat, this.lng});

  MarkPosition.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latitude'] = lat;
    data['longitude'] = lng;
    return data;
  }
}
