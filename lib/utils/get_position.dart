import 'package:geolocator/geolocator.dart';
import 'package:vector_math/vector_math_64.dart' as Vector;

Future<List<double>> getPosition() async {
  List<Position> pos = [];

  for (int i = 0; i < 3; i++) {
    pos.add(
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best
      )
    );
    await Future.delayed(const Duration(milliseconds: 150));
  }

  final denominator = Vector.Matrix3(
    pos[0].latitude, pos[0].longitude, 1,
    pos[1].latitude, pos[1].longitude, 1,
    pos[2].latitude, pos[2].longitude, 1
  ).determinant();

  if (denominator == 0.0) {
    return [
      (pos[0].latitude + pos[1].latitude + pos[2].latitude) / 3,
      (pos[0].longitude + pos[1].longitude + pos[2].longitude) / 3
    ];
  }

  final moleculeLat = Vector.Matrix3(
    -(pos[0].latitude * pos[0].latitude + pos[0].longitude * pos[0].longitude), pos[0].longitude, 1,
    -(pos[1].latitude * pos[1].latitude + pos[1].longitude * pos[1].longitude), pos[1].longitude, 1,
    -(pos[2].latitude * pos[2].latitude + pos[2].longitude * pos[2].longitude), pos[2].longitude, 1,
  ).determinant();

  final moleculeLng = Vector.Matrix3(
    pos[0].latitude, -(pos[0].latitude * pos[0].latitude + pos[0].longitude * pos[0].longitude), 1,
    pos[1].latitude, -(pos[1].latitude * pos[1].latitude + pos[1].longitude * pos[1].longitude), 1,
    pos[2].latitude, -(pos[2].latitude * pos[2].latitude + pos[2].longitude * pos[2].longitude), 1,
  ).determinant();

  return [(moleculeLat / denominator) / -2, (moleculeLng / denominator) / -2];
}
