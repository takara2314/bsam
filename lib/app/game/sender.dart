import 'package:bsam/app/game/action.dart';
import 'package:bsam/app/game/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_use/flutter_use.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';

const sendingGeolocationInterval = Duration(seconds: 1);

void useGeolocationSender(
  BuildContext context,
  Game game,
  GeolocationState geolocation,
) {
  useInterval(() {
    if (!game.connected || !geolocation.fetched || !context.mounted) {
      return;
    }

    debugPrint("位置情報を送信しますよ！");

    game.action.sendPostGeolocationAction(
      PostGeolocationActionMessage(
        latitude: geolocation.position!.latitude,
        longitude: geolocation.position!.longitude,
        altitudeMeter: geolocation.position!.altitude,
        accuracyMeter: geolocation.position!.accuracy,
        altitudeAccuracyMeter: geolocation.position!.altitudeAccuracy,
        heading: geolocation.position!.heading,
        speedMeterPerSec: geolocation.position!.speed,
        recordedAt: geolocation.position!.timestamp,
      )
    );
  }, sendingGeolocationInterval);
}
