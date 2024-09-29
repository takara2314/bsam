import 'package:bsam/app/game/announcer.dart';
import 'package:bsam/app/game/judgement.dart';
import 'package:bsam/app/game/sender.dart';
import 'package:bsam/app/voice/voice.dart';
import 'package:bsam/domain/distance.dart';
import 'package:bsam/presentation/widgets/icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_use_geolocation/flutter_use_geolocation.dart';
import 'package:bsam/app/game/game.dart';
import 'package:bsam/app/jwt/jwt.dart';
import 'package:bsam/main.dart';
import 'package:bsam/presentation/widgets/compass.dart';
import 'package:bsam/presentation/widgets/text.dart';
import 'package:bsam/provider.dart';

const defaultWantMarkCounts = 3;

class RacePage extends HookConsumerWidget {
  final String athleteId;

  const RacePage({
    required this.athleteId,
    super.key
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final jwt = Jwt.fromToken(tokenNotifier.state);

    // TODO: 仮の値のため、実際の値に変更する
    final raceName = useState('サンプルレース');

    // コンパスの角度
    final compassDegree = useState<double?>(null);
    // 次のマークまでの距離
    final distanceToNextMarkMeter = useState<double?>(null);

    // レースサーバークライアント
    final gameProvider = ChangeNotifierProvider((ref) => Game(
      tokenNotifier.state,
      jwt.associationId,
      athleteId,
      defaultWantMarkCounts,
    ));

    final game = ref.watch(gameProvider);

    // 位置情報を取得する
    final geolocation = useGeolocation(
      locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    ));

    // アナウンスに使用するTTS
    final voice = useVoice(
      'ja-JP',
      0.6,
      1.0,
      1.0,
    );

    // アナウンスを行う
    final announcer = useAnnouncer(
      context,
      voice,
      game.started,
      game.navigate.nextMarkLabel.nameKatakana,
      compassDegree.value,
      distanceToNextMarkMeter.value,
    );

    // マークの通過判定を行う
    useJudgement(
      distanceToNextMarkMeter.value,
      () {
        final passedMarkNameKatakana = game.navigate.nextMarkLabel.nameKatakana;
        game.navigate.passMark(game.navigate.nextMarkNo);
        announcer.announceMarkPassedRepeatedly(passedMarkNameKatakana);
      }
    );

    // 定期的に位置情報を送信する
    useGeolocationSender(
      context,
      game,
      geolocation,
    );

    // レースサーバーに接続する
    useEffect(() {
      game.connect();

      return () {
        if (game.connected) {
          game.disconnect();
        }
      };
    }, []);

    // 位置情報を取得したら、コンパスの角度と次のマークまでの距離を計算する
    useEffect(() {
      if (!geolocation.fetched) {
        return;
      }

      compassDegree.value = game.navigate.calcNextMarkCompassDeg(
        geolocation.position!.latitude,
        geolocation.position!.longitude,
        geolocation.position!.heading
      );

      distanceToNextMarkMeter.value = game.navigate.calcNextMarkDistanceMeter(
        geolocation.position!.latitude,
        geolocation.position!.longitude
      );

      return null;
    }, [geolocation]);

    return Scaffold(
      appBar: RaceAppBar(
        raceName: raceName.value,
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: game.started
          ? RaceStarted(
            compassDegree: compassDegree.value,
            nextMarkNo: game.navigate.nextMarkNo,
            nextMarkName: game.navigate.nextMarkLabel.name,
            distanceToNextMarkMeter: distanceToNextMarkMeter.value,
            geolocation: geolocation
          )
          : RaceWaiting(
            geolocation: geolocation
          )
      )
    );
  }
}

class RaceAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String raceName;

  const RaceAppBar({
    required this.raceName,
    required this.preferredSize,
    super.key
  });

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      centerTitle: false,
      title: Text(
        raceName,
        style: const TextStyle(
          color: bodyTextColor,
          fontSize: bodyTextSize,
          fontWeight: FontWeight.bold
        ),
      ),
    );
  }
}

class RaceWaiting extends StatelessWidget {
  final GeolocationState geolocation;

  const RaceWaiting({
    required this.geolocation,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: const AppIcon(
            size: 200
          )
        ),
        const NormalText('レース開始をお待ちください...'),
        RaceMarkSensorInfo(
          latitude: geolocation.position?.latitude ?? 0,
          longitude: geolocation.position?.longitude ?? 0,
          accuracyMeter: geolocation.position?.accuracy ?? 0,
          heading: geolocation.position?.heading ?? 0,
          compassDegree: 0,
          showingCompass: false
        )
      ]
    );
  }
}

class RaceStarted extends StatelessWidget {
  final double? compassDegree;
  final int nextMarkNo;
  final String nextMarkName;
  final double? distanceToNextMarkMeter;
  final GeolocationState geolocation;

  const RaceStarted({
    required this.compassDegree,
    required this.nextMarkNo,
    required this.nextMarkName,
    required this.distanceToNextMarkMeter,
    required this.geolocation,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaceCompass(heading: compassDegree),
        RaceMarkDirectionInfo(
          nextMarkNo: nextMarkNo,
          nextMarkName: nextMarkName,
          distanceToNextMarkMeter: distanceToNextMarkMeter
        ),
        RaceMarkSensorInfo(
          latitude: geolocation.position?.latitude ?? 0,
          longitude: geolocation.position?.longitude ?? 0,
          accuracyMeter: geolocation.position?.accuracy ?? 0,
          heading: geolocation.position?.heading ?? 0,
          compassDegree: compassDegree
        )
      ]
    );
  }
}

class RaceCompass extends StatelessWidget {
  final double? heading;

  const RaceCompass({
    required this.heading,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: CustomPaint(
        painter: Compass(heading: heading ?? 0.0)
      )
    );
  }
}

class RaceMarkDirectionInfo extends StatelessWidget {
  final int nextMarkNo;
  final String nextMarkName;
  final double? distanceToNextMarkMeter;

  const RaceMarkDirectionInfo({
    required this.nextMarkNo,
    required this.nextMarkName,
    required this.distanceToNextMarkMeter,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    String distanceToNextMarkMeterForLabel;
    if (distanceToNextMarkMeter != null) {
      distanceToNextMarkMeterForLabel = getAnnounceDistanceMeter(distanceToNextMarkMeter!).toString();
    } else {
      distanceToNextMarkMeterForLabel = '?';
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaceMarkNoIcon(markNo: nextMarkNo),
              Heading('$nextMarkNameマーク', fontSize: 24)
            ]
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 7),
              child: Heading(
                '残り 約',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                distanceToNextMarkMeterForLabel,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 40,
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 7),
              child: Heading(
                'm',
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ]
        ),
      ]
    );
  }
}

class RaceMarkNoIcon extends StatelessWidget {
  final int markNo;

  const RaceMarkNoIcon({
    required this.markNo,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      margin: const EdgeInsets.only(right: 10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(9999)
      ),
      child: Text(
        '$markNo',
        style: const TextStyle(
          color: Colors.white,
          fontSize: bodyHeadingSize,
          fontWeight: FontWeight.bold
        )
      )
    );
  }
}

class RaceMarkSensorInfo extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double accuracyMeter;
  final double heading;
  final double? compassDegree;
  final bool showingCompass;

  const RaceMarkSensorInfo({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.compassDegree,
    this.showingCompass = true,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    String compassDegreeForLabel;
    if (compassDegree != null) {
      compassDegreeForLabel = '${compassDegree!.toStringAsFixed(2)}°';
    } else {
      compassDegreeForLabel = '?°';
    }

    return Container(
      margin: const EdgeInsets.only(top: 20, left: 30, right: 30),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(3),
          1: FlexColumnWidth(5),
        },
        children: [
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('緯度 / 経度'),
              RaceMarkSensorInfoValueCell(
                '${latitude.toStringAsFixed(6)} / ${longitude.toStringAsFixed(6)}'
              ),
            ],
          ),
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('位置情報の精度'),
              RaceMarkSensorInfoValueCell(
                '${accuracyMeter.toStringAsFixed(2)}m'
              ),
            ],
          ),
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('方向の角度'),
              RaceMarkSensorInfoValueCell(
                '${heading.toStringAsFixed(2)}°'
              ),
            ],
          ),
          if (showingCompass)
            TableRow(
              children: [
                const RaceMarkSensorInfoLabelCell('コンパスの角度'),
                RaceMarkSensorInfoValueCell(compassDegreeForLabel),
              ],
            )
        ]
      )
    );
  }
}

class RaceMarkSensorInfoLabelCell extends StatelessWidget {
  final String label;

  const RaceMarkSensorInfoLabelCell(
    this.label,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.middle,
      child: NormalText(label)
    );
  }
}

class RaceMarkSensorInfoValueCell extends StatelessWidget {
  final String value;

  const RaceMarkSensorInfoValueCell(
    this.value,
    {super.key}
  );

  @override
  Widget build(BuildContext context) {
    return TableCell(
      child: StrongText(value)
    );
  }
}
