import 'package:bsam/app/game/action.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_use/flutter_use.dart';
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

    final game = useState<Game>(Game(
      tokenNotifier.state,
      jwt.associationId,
      athleteId,
      defaultWantMarkCounts,
    ));

    // TODO: 仮の値のため、実際の値に変更する
    final raceName = useState('サンプルレース');
    final nextMarkNo = useState(1);
    final nextMarkName = useState('上マーク');

    final compassDegree = useState(0.0);
    final distanceToNextMarkMeter = useState(46.5);

    final geolocation = useGeolocation(
      locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    ));

    useInterval(() {
      if (!game.value.connected || !geolocation.fetched) {
        return;
      }

      game.value.action.sendPostGeolocationAction(
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
    }, const Duration(seconds: 1));

    useEffect(() {
      game.value.connect();

      return () {
        if (game.value.connected) {
          game.value.disconnect();
        }
      };
    }, []);

    return Scaffold(
      appBar: RaceAppBar(
        raceName: raceName.value,
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: Column(
          children: [
            RaceCompass(heading: compassDegree.value),
            RaceMarkDirectionInfo(
              nextMarkNo: nextMarkNo.value,
              nextMarkName: nextMarkName.value,
              distanceToNextMarkMeter: distanceToNextMarkMeter.value
            ),
            RaceMarkSensorInfo(
              latitude: geolocation.position?.latitude ?? 0,
              longitude: geolocation.position?.longitude ?? 0,
              accuracyMeter: geolocation.position?.accuracy ?? 0,
              heading: geolocation.position?.heading ?? 0,
              compassDegree: compassDegree.value
            )
          ]
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

class RaceCompass extends StatelessWidget {
  final double heading;

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
        painter: Compass(heading: heading)
      )
    );
  }
}

class RaceMarkDirectionInfo extends StatelessWidget {
  final int nextMarkNo;
  final String nextMarkName;
  final double distanceToNextMarkMeter;

  const RaceMarkDirectionInfo({
    required this.nextMarkNo,
    required this.nextMarkName,
    required this.distanceToNextMarkMeter,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 40, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RaceMarkNoIcon(markNo: nextMarkNo),
              Heading(nextMarkName, fontSize: 24)
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
                '${distanceToNextMarkMeter.round()}',
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
  final double compassDegree;

  const RaceMarkSensorInfo({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeter,
    required this.heading,
    required this.compassDegree,
    super.key
  });

  @override
  Widget build(BuildContext context) {
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
          TableRow(
            children: [
              const RaceMarkSensorInfoLabelCell('コンパスの角度'),
              RaceMarkSensorInfoValueCell(
                '${compassDegree.toStringAsFixed(2)}°'
              ),
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
