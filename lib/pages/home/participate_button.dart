import 'package:bsam/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsam/pages/navi/page.dart';
import 'package:bsam/constants/app_constants.dart';

class ParticipateButton extends ConsumerWidget {
  const ParticipateButton({
    super.key,
    required this.assocId,
    required this.userId,
    required this.ttsLanguage,
  });

  final String? assocId;
  final String? userId;
  final String ttsLanguage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isEnabled = assocId != null && userId != null;

    // 固定値の設定
    const ttsVolume = AppConstants.ttsVolumeInit;
    const ttsPitch = AppConstants.ttsPitchInit;
    const headingFix = AppConstants.headingFixInit;
    const isAnnounceNeighbors = false;

    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.9,
      child: ElevatedButton(
        onPressed: isEnabled
          ? () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Navi(
                    assocId: assocId!,
                    userId: userId!,
                    ttsLanguage: ttsLanguage,
                    ttsVolume: ttsVolume,
                    ttsPitch: ttsPitch,
                    headingFix: headingFix,
                    isAnnounceNeighbors: isAnnounceNeighbors,
                  ),
                ),
              );
            }
          : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
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
