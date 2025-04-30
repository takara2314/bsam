import 'package:geolocator/geolocator.dart';

/// 方角名を返す関数
String getDegName(double deg) {
  if (deg >= -15 && deg < 15) {
    return '前';
  }
  if (deg >= 15 && deg < 60) {
    return 'やや右前';
  }
  if (deg >= 60 && deg < 120) {
    return '右';
  }
  if (deg >= 120 && deg < 150) {
    return 'やや右後ろ';
  }
  if (deg >= 150 || deg < -150) {
    return '後ろ';
  }
  if (deg >= -150 && deg < -120) {
    return 'やや左後ろ';
  }
  if (deg >= -120 && deg < -60) {
    return '左';
  }
  if (deg >= -60 && deg < -15) {
    return 'やや左前';
  }

  return '不明';
}

/// 方位角の計算
double calculateCompassDegree(double heading, double currentLat, double currentLng, 
    double targetLat, double targetLng) {
  if (currentLat == 0.0 && currentLng == 0.0) {
    return 0;
  }

  double bearingDeg = Geolocator.bearingBetween(
    currentLat,
    currentLng,
    targetLat,
    targetLng,
  );

  double diff = bearingDeg - heading;

  if (diff > 180) {
    diff -= 360;
  } else if (diff < -180) {
    diff += 360;
  }

  return diff;
}

/// 方位角の補正
double correctHeading(double heading, double headingFix) {
  double correctedHeading = heading + headingFix;

  if (correctedHeading > 180.0) {
    correctedHeading = -360.0 + correctedHeading;
  }

  return correctedHeading;
}
