import 'package:bsam/app/voice/voice.dart';
import 'package:bsam/domain/direction.dart';
import 'package:bsam/domain/distance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const periodicAnnounceInterval = Duration(seconds: 3);
const passedAnnounceNum = 3;
const passedAnnounceInterval = Duration(seconds: 1);

class UseAnnouncer {
  final Future<void> Function(String) announceMarkPassedRepeatedly;

  UseAnnouncer({
    required this.announceMarkPassedRepeatedly,
  });
}

UseAnnouncer useAnnouncer(
  BuildContext context,
  UseVoice voice,
  bool startedRace,
  String markNameKatakana,
  double? compassDegree,
  double? distanceToNextMarkMeter,
) {
  final enabledPeriodicAnnounce = useState(false);

  // マークの方向と距離をアナウンスする
  Future<void> announceMarkDirectionDistance() async {
    // コンパスの角度と次のマークまでの距離が不明の場合は、「不明」とアナウンスする
    if (compassDegree == null || distanceToNextMarkMeter == null) {
      await voice.speak('次のマークがどこにあるかわかりません');
      return;
    }

    final directionName = getDirectionName(compassDegree);
    final distance = getAnnounceDistanceMeter(distanceToNextMarkMeter);

    await voice.speak('$markNameKatakana、$directionName、$distance');
  }

  // マーク通過を1回アナウンスする
  Future<void> announcePassedOnce(
    String passedMarkNameKatakana,
  ) async {
    await voice.speak('$passedMarkNameKatakanaに到達');
  }

  // マーク通過を複数回アナウンスする
  Future<void> announceMarkPassedRepeatedly(
    String passedMarkNameKatakana,
  ) async {
    enabledPeriodicAnnounce.value = false;

    for (int i = 0; i < passedAnnounceNum; i++) {
      await announcePassedOnce(passedMarkNameKatakana);

      if (context.mounted) {
        await Future.delayed(passedAnnounceInterval);
      } else {
        return;
      }
    }

    enabledPeriodicAnnounce.value = true;
  }

  // 定期的なアナウンスを開始する
  Future<void> startPeriodicAnnounce(Duration interval) async {
    while (true) {
      await announceMarkDirectionDistance();

      if (context.mounted) {
        await Future.delayed(interval);
      } else {
        return;
      }
    }
  }

  // レース開始時に定期的なアナウンスを有効にする
  useEffect(() {
    enabledPeriodicAnnounce.value = startedRace;

    return () {};
  }, [startedRace]);

  // 定期的なアナウンスの有効/無効に応じてアナウンスを開始/停止する
  useEffect(() {
    if (enabledPeriodicAnnounce.value) {
      debugPrint("定期的なアナウンスを開始する");
      startPeriodicAnnounce(periodicAnnounceInterval);
    } else {
      debugPrint("定期的なアナウンスを停止する");
      voice.stop();
    }

    return () {
      voice.stop();
    };
  }, [enabledPeriodicAnnounce]);

  return UseAnnouncer(
    announceMarkPassedRepeatedly: announceMarkPassedRepeatedly,
  );
}
