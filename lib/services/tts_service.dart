import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:async_locks/async_locks.dart';

/// 音声読み上げサービス
class TtsService {
  final FlutterTts _tts = FlutterTts();
  final Lock _speakLock = Lock();

  late String _language;
  late double _speechRate;
  late double _volume;
  late double _pitch;

  TtsService();

  /// TTSの初期化
  Future<void> initialize(
    String language,
    double speechRate,
    double volume,
    double pitch
  ) async {
    _language = language;
    _speechRate = speechRate;
    _volume = volume;
    _pitch = pitch;

    await _tts.setLanguage(_language);
    await _tts.setSpeechRate(_speechRate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.awaitSpeakCompletion(true);
  }

  /// スピード設定
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate; // Update the field
    await _tts.setSpeechRate(_speechRate);
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
        await initialize(_language, _speechRate, _volume, _pitch);
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
