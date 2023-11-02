import 'package:flutter/material.dart';

import 'package:bsam/pages/navi/page.dart';

class ParticipateButton extends StatelessWidget {
  const ParticipateButton({
    super.key,
    required this.assocId,
    required this.userId,
    required this.ttsSpeed,
    required this.ttsDuration,
    required this.headingFix,
    required this.isAnnounceNeighbors
  });

  final String? assocId;
  final String? userId;
  final double ttsSpeed;
  final double ttsDuration;
  final double headingFix;
  final bool isAnnounceNeighbors;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.9,
      child: ElevatedButton(
        onPressed:
          userId != null || assocId != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Navi(
                      assocId: assocId!,
                      userId: userId!,
                      ttsSpeed: ttsSpeed,
                      ttsDuration: ttsDuration,
                      headingFix: headingFix,
                      isAnnounceNeighbors: isAnnounceNeighbors
                    ),
                  )
                );
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          padding: const EdgeInsets.only(top: 20, bottom: 20)
        ),
        child: const Text(
          'レースに参加する',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20
          )
        )
      ),
    );
  }
}
