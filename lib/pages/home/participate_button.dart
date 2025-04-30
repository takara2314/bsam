import 'package:flutter/material.dart';

import 'package:bsam/pages/navi/page.dart';

class ParticipateButton extends StatelessWidget {
  const ParticipateButton({
    super.key,
    required this.assocId,
    required this.userId,
    required this.ttsLanguage,
    required this.ttsSpeed,
    required this.ttsVolume,
    required this.ttsPitch,
    required this.ttsDuration,
    required this.reachJudgeRadius,
    required this.reachNoticeNum,
    required this.headingFix,
    required this.isAnnounceNeighbors,
    required this.markNameType
  });

  final String? assocId;
  final String? userId;
  final String ttsLanguage;
  final double ttsSpeed;
  final double ttsVolume;
  final double ttsPitch;
  final double ttsDuration;
  final int reachJudgeRadius;
  final int reachNoticeNum;
  final double headingFix;
  final bool isAnnounceNeighbors;
  final int markNameType;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.9,
      child: ElevatedButton(
        onPressed:
          userId != null && assocId != null
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Navi(
                      assocId: assocId!,
                      userId: userId!,
                      ttsLanguage: ttsLanguage,
                      ttsSpeed: ttsSpeed,
                      ttsVolume: ttsVolume,
                      ttsPitch: ttsPitch,
                      ttsDuration: ttsDuration,
                      reachJudgeRadius: reachJudgeRadius,
                      reachNoticeNum: reachNoticeNum,
                      headingFix: headingFix,
                      isAnnounceNeighbors: isAnnounceNeighbors,
                      markNameType: markNameType
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
