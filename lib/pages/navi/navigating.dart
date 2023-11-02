import 'package:flutter/material.dart';

import 'package:bsam/widgets/compass.dart';

class Navigating extends StatelessWidget {
  const Navigating({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.heading,
    required this.compassDeg,
    required this.markNames,
    required this.nextMarkNo,
    required this.routeDistance,
    required this.forcePassed,
    required this.onPassed
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final double compassDeg;
  final Map<int, List<String>> markNames;
  final int nextMarkNo;
  final double routeDistance;
  final void Function(int) forcePassed;
  final void Function() onPassed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.only(top: 30, bottom: 30),
          child: SizedBox(
            width: 250,
            height: 250,
            child: CustomPaint(
              painter: Compass(heading: compassDeg)
            )
          )
        ),
        Text(
          '$nextMarkNo ${markNames[nextMarkNo]![0]}マーク',
          style: const TextStyle(
            fontSize: 28
          )
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              '残り 約',
              style: TextStyle(
                color: Color.fromRGBO(79, 79, 79, 1),
                fontSize: 28
              )
            ),
            Container(
              margin: const EdgeInsets.only(left: 10, right: 10),
              child: Text(
                '${routeDistance.toInt()}',
                style: const TextStyle(
                  color: Color.fromRGBO(79, 79, 79, 1),
                  fontSize: 36
                )
              )
            ),
            const Text(
              'm',
              style: TextStyle(
                color: Color.fromRGBO(79, 79, 79, 1),
                fontSize: 28
              )
            )
          ],
        ),
        Text(
          '緯度 / 経度',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${latitude.toStringAsFixed(6)} / ${longitude.toStringAsFixed(6)}'
        ),
        Text(
          '位置情報の精度',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${accuracy.toStringAsFixed(2)} m'
        ),
        Text(
          '端末の方角 / コンパスの方角',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${heading.toStringAsFixed(2)}° / ${compassDeg.toStringAsFixed(2)}°'
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {forcePassed(1);},
              child: const Text('上通過')
            ),
            TextButton(
              onPressed: () {forcePassed(2);},
              child: const Text('サイド通過')
            ),
            TextButton(
              onPressed: () {forcePassed(3);},
              child: const Text('下通過')
            ),
            TextButton(
              onPressed: () {onPassed();},
              child: const Text('マーク通過判定')
            )
          ]
        )
      ]
    );
  }
}
