import 'package:flutter/material.dart';
import 'package:bsam/pages/navi/compass_area.dart';

class Navigating extends StatefulWidget {
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
    required this.maxDistance,
    required this.forcePassed,
    required this.onPassed,
    required this.markNameType
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final double compassDeg;
  final Map<int, List<String>> markNames;
  final int nextMarkNo;
  final double routeDistance;
  final int maxDistance;
  final void Function(int) forcePassed;
  final void Function() onPassed;
  final int markNameType;

  @override
  State<Navigating> createState() => _NavigatingState();
}

class _NavigatingState extends State<Navigating> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CompassArea(
          compassDeg: widget.compassDeg
        ),
        Text(
          widget.markNameType == 0
            ? '${widget.nextMarkNo} ${widget.markNames[widget.nextMarkNo]![0]}マーク'
            : '${widget.markNames[widget.nextMarkNo]![0]}マーク',
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
                '${widget.routeDistance < widget.maxDistance ? widget.routeDistance.toInt() : '?'}',
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
          '${widget.latitude.toStringAsFixed(6)} / ${widget.longitude.toStringAsFixed(6)}'
        ),
        Text(
          '位置情報の精度',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${widget.accuracy.toStringAsFixed(2)} m'
        ),
        Text(
          '端末の方角 / コンパスの方角',
          style: Theme.of(context).textTheme.displaySmall
        ),
        Text(
          '${widget.heading.toStringAsFixed(2)}° / ${widget.compassDeg.toStringAsFixed(2)}°'
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {widget.forcePassed(1);},
              child: const Text('上通過')
            ),
            TextButton(
              onPressed: () {widget.forcePassed(2);},
              child: const Text('サイド通過')
            ),
            TextButton(
              onPressed: () {widget.forcePassed(3);},
              child: const Text('下通過')
            ),
            TextButton(
              onPressed: () {widget.onPassed();},
              child: const Text('マーク通過判定')
            )
          ]
        )
      ]
    );
  }
}
