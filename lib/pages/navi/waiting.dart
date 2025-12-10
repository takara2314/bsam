import 'package:flutter/material.dart';

class Waiting extends StatelessWidget {
  const Waiting({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.heading,
    required this.compassDeg,
  });

  final double latitude;
  final double longitude;
  final double accuracy;
  final double heading;
  final double compassDeg;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(right: 15, left: 15),
      child: Column(
        children: [
          Text('レースは始まっていません', style: Theme.of(context).textTheme.displayLarge),
          const Text('スタートボタンが押されるまでお待ちください。'),
          Text('緯度 / 経度', style: Theme.of(context).textTheme.displaySmall),
          Text(
            '${latitude.toStringAsFixed(6)} / ${longitude.toStringAsFixed(6)}',
          ),
          Text('位置情報の精度', style: Theme.of(context).textTheme.displaySmall),
          Text('$accuracy m'),
          Text(
            '端末の方角 / コンパスの方角',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            '${heading.toStringAsFixed(2)}° / ${compassDeg.toStringAsFixed(2)}°',
          ),
        ],
      ),
    );
  }
}
