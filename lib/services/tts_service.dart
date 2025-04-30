import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:async_locks/async_locks.dart';
import 'package:bsam/constants/app_constants.dart';

/// 音声読み上げサービス
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final Lock _speakLock = Lock();

  TtsService();

  /// TTSの初期化
  Future<void> initialize(double speechRate) async {
    await _tts.setLanguage(AppConstants.ttsLanguage);
    await _tts.setSpeechRate(speechRate);
    await _tts.setVolume(AppConstants.ttsVolume);
    await _tts.setPitch(AppConstants.ttsPitch);
    await _tts.awaitSpeakCompletion(true);
  }

  /// スピード設定
  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  /// 読み上げを一時停止
  Future<void> pause() async {
    await _tts.pause();
  }

  /// テキストを読み上げる
  Future<void> speak(String text) async {
    // 非同期による同時の発話を防ぐ (MethodChannelでクラッシュするため)
    await _speakLock.run(() async {
      try {
        // TTSの仕様で 46 のみ英語の発音なので、ひらがな読みにする
        text = text.replaceAll('46', 'よんじゅうろく');

        await _tts.speak(text);
      } catch (e) {
        debugPrint('TTS error: ${e.toString()}');
        await initialize(AppConstants.ttsSpeedInit);
      }
    });
  }

  /// 複数回読み上げる
  Future<void> speakMultiple(String text, int count, {int delaySeconds = 1}) async {
    for (int i = 0; i < count; i++) {
      await speak(text);
      if (i < count - 1) {
        await Future.delayed(Duration(seconds: delaySeconds));
      }
    }
  }
}
