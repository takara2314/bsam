import 'package:bsam/models/mark.dart';

List<Mark> updateMarksOnEnable(List<Mark> current, List<Mark> received) {
  final result = List.of(current);

  for (int i = 0; i < received.length; i++) {
    if (received[i].position!.lat == 0.0 && received[i].position!.lng == 0.0) {
      continue;
    }
    result[i] = received[i];
  }

  return result;
}
