import 'package:bsam/domain/judge.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

void useJudgement(
  double? distanceToNextMarkMeter,
  void Function() onPassedMark,
) {
  useEffect(() {
    if (distanceToNextMarkMeter == null) {
      return;
    }

    if (distanceToNextMarkMeter < passingDistanceMeter) {
      onPassedMark();
    }
    return null;
  }, [distanceToNextMarkMeter]);
}
