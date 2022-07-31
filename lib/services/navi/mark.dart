import 'package:bsam/models/navi.dart';

List<MarkPosition> updateMarksOnEnable(List<MarkPosition> base, List<dynamic> received) {
  final result = List.of(base);

  for (int i = 0; i < received.length; i++) {
    if (received[i].lat == 0.0 && received[i].lng == 0.0) {
      continue;
    }
    result[i] = received[i];
  }

  return result;
}
