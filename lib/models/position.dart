class Position {
  double? lat;
  double? lng;

  Position({this.lat, this.lng});

  Position.fromJson(Map<String, dynamic> json) {
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
  }
}
