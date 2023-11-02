import 'package:flutter/material.dart';
import 'dart:async';
import 'package:bsam/widgets/compass.dart';

class CompassArea extends StatefulWidget {
  const CompassArea({
    super.key,
    required this.compassDeg
  });

  final double compassDeg;

  @override
  CompassAreaState createState() => CompassAreaState();
}

class CompassAreaState extends State<CompassArea> {
  double _compassDegShowing = 0;

  @override
  void initState() {
    super.initState();

    Timer.periodic(
      const Duration(milliseconds: 10),
      _calcCompassDeg
    );
  }

  _calcCompassDeg(Timer timer) {
    if (!mounted) {
      return;
    }
    setState(() {
      _compassDegShowing += (widget.compassDeg - _compassDegShowing) * 0.1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30, bottom: 30),
      child: SizedBox(
        width: 250,
        height: 250,
        child: CustomPaint(
          painter: Compass(heading: _compassDegShowing)
        )
      )
    );
  }
}
