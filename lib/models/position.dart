class PositionWithId {
  String? userId;
  double? lat;
  double? lng;

  PositionWithId({
    this.userId,
    this.lat,
    this.lng
  });

  PositionWithId.fromJson(Map<String, dynamic> json) {
    userId = json['user_id'];
    lat = json['latitude'].toDouble();
    lng = json['longitude'].toDouble();
  }
}
