import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:bsam/constants/app_constants.dart';
import 'package:bsam/models/position.dart';

/// 位置情報サービス
class LocationService {
  /// 現在位置を取得
  Future<geo.Position?> getCurrentPosition() async {
    try {
      geo.Position pos = await geo.Geolocator.getCurrentPosition(
        locationSettings: const geo.LocationSettings(
          accuracy: geo.LocationAccuracy.best,
        ),
      );

      // 精度が閾値以下の場合はnullを返す
      if (pos.accuracy > AppConstants.locationAccuracyThreshold) {
        return null;
      }

      return pos;
    } catch (e) {
      debugPrint('Location error: ${e.toString()}');
      return null;
    }
  }

  /// 2点間の距離を計算
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    if (lat1 == 0.0 && lng1 == 0.0 || lat2 == 0.0 && lng2 == 0.0) {
      return double.infinity;
    }

    return geo.Geolocator.distanceBetween(lat1, lng1, lat2, lng2);
  }

  /// 2点間の角度を計算
  double calculateBearing(double lat1, double lng1, double lat2, double lng2) {
    if (lat1 == 0.0 && lng1 == 0.0 || lat2 == 0.0 && lng2 == 0.0) {
      return 0.0;
    }

    return geo.Geolocator.bearingBetween(lat1, lng1, lat2, lng2);
  }

  /// Positionオブジェクトから自作Positionモデルに変換
  Position createPositionModel(geo.Position geoPosition) {
    return Position(
      lat: geoPosition.latitude,
      lng: geoPosition.longitude,
      acc: geoPosition.accuracy,
    );
  }
}
