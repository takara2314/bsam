import 'package:bsam/main.dart';
import 'package:bsam/presentation/widgets/compass.dart';
import 'package:bsam/presentation/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class RacePage extends HookConsumerWidget {
  const RacePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 仮の値のため、実際の値に変更する
    final raceName = useState('サンプルレース');
    final compassHeading = useState(0.0);
    final nextMarkNo = useState(1);
    final nextMarkName = useState('上マーク');
    final distanceToNextMarkMeter = useState(46.5);

    return Scaffold(
      appBar: RaceAppBar(
        raceName: raceName.value,
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: Column(
          children: [
            RaceCompass(heading: compassHeading.value),
            RaceMarkDirectionInfo(
              nextMarkNo: nextMarkNo.value,
              nextMarkName: nextMarkName.value,
              distanceToNextMarkMeter: distanceToNextMarkMeter.value
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
