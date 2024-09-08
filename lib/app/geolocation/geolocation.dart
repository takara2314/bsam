import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';

class UseGeolocation {
  final double latitude;
  final double longitude;
  final double altitudeMeter;
  final double accuracyMeter;
  final double altitudeAccuracyMeter;
  final double heading;
  final double speedMeterPerSec;

  UseGeolocation({
    required this.latitude,
    required this.longitude,
    required this.altitudeMeter,
    required this.accuracyMeter,
    required this.altitudeAccuracyMeter,
    required this.heading,
    required this.speedMeterPerSec,
  });
}

UseGeolocation useGeolocation() {
  final latitude = useState(0.0);
  final longitude = useState(0.0);
  final altitudeMeter = useState(0.0);
  final accuracyMeter = useState(0.0);
  final altitudeAccuracyMeter = useState(0.0);
  final heading = useState(0.0);
  final speedMeterPerSec = useState(0.0);

  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.best,
    distanceFilter: 0,
  );
  Geolocator.getPositionStream(
    locationSettings: locationSettings
  ).listen((Position? position) {
    if (position == null) {
      return;
    }

    latitude.value = position.latitude;
    longitude.value = position.longitude;
    altitudeMeter.value = position.altitude;
    accuracyMeter.value = position.accuracy;
    altitudeAccuracyMeter.value = position.altitudeAccuracy;
    heading.value = position.heading;
    speedMeterPerSec.value = position.speed;
  });

  return UseGeolocation(
    latitude: latitude.value,
    longitude: longitude.value,
    altitudeMeter: altitudeMeter.value,
    accuracyMeter: accuracyMeter.value,
    altitudeAccuracyMeter: altitudeAccuracyMeter.value,
    heading: heading.value,
    speedMeterPerSec: speedMeterPerSec.value,
  );
}
