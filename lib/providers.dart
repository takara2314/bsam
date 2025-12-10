import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:bsam/constants/app_constants.dart';

// --- 認証関連のProvider ---
final serverUrlProvider = StateProvider<String?>((ref) => null);
final wavenetTokenProvider = StateProvider<String?>((ref) => null);
final assocIdProvider = StateProvider<String?>((ref) => null);
final jwtProvider = StateProvider<String?>((ref) => null);
final userIdProvider = StateProvider<String?>((ref) => null);

// --- ネットワーク接続状態Provider ---
final connectivityProvider = StateProvider<ConnectivityResult>(
  (ref) => ConnectivityResult.none,
);

// --- 設定管理関連 ---
// 設定が読み込まれたかどうかを追跡するProvider
final settingsLoadedProvider = StateProvider<bool>((ref) => false);

// TTS関連の設定
final ttsSpeedProvider = StateProvider<double>((ref) {
  return AppConstants.ttsSpeedInit;
});

final ttsDurationProvider = StateProvider<double>((ref) {
  return AppConstants.ttsDurationInit;
});

// ナビゲーション関連の設定
final reachJudgeRadiusProvider = StateProvider<int>((ref) {
  return AppConstants.reachJudgeRadiusInit;
});

final reachNoticeNumProvider = StateProvider<int>((ref) {
  return AppConstants.reachNoticeNumInit;
});

final markNameTypeProvider = StateProvider<int>((ref) {
  return AppConstants.markNameTypeInit;
});

// --- 設定管理のヘルパー関数 ---

/// 指定した設定値を更新し、SharedPreferencesに保存する
Future<void> updateSetting<T>(
  StateController<T> controller,
  String key,
  T value,
) async {
  final prefs = await SharedPreferences.getInstance();
  controller.state = value;
  if (value is double) {
    await prefs.setDouble(key, value);
  } else if (value is int) {
    await prefs.setInt(key, value);
  } else if (value is String) {
    await prefs.setString(key, value);
  } else if (value is bool) {
    await prefs.setBool(key, value);
  }
}

/// 指定したStateProviderの値を更新し、SharedPreferencesに保存する（Widgetから使いやすいバージョン）
Future<void> updateSettingValue<T>({
  required WidgetRef ref,
  required StateProvider<T> provider,
  required String key,
  required T value,
}) async {
  ref.read(provider.notifier).state = value;
  final prefs = await SharedPreferences.getInstance();

  if (value is double) {
    await prefs.setDouble(key, value);
  } else if (value is int) {
    await prefs.setInt(key, value);
  } else if (value is String) {
    await prefs.setString(key, value);
  } else if (value is bool) {
    await prefs.setBool(key, value);
  }
}

/// Slide設定の変更時に使用する関数
Future<void> updateSliderSetting({
  required WidgetRef ref,
  required StateProvider<double> provider,
  required String key,
  required double value,
}) async {
  return updateSettingValue(
    ref: ref,
    provider: provider,
    key: key,
    value: value,
  );
}

/// TextForm設定の変更時に使用する関数
Future<void> updateTextFormSetting<T extends num>({
  required WidgetRef ref,
  required StateProvider<T> provider,
  required String key,
  required String newValue,
  required T defaultValue,
  bool isDouble = false,
}) async {
  T parsedValue;
  try {
    if (isDouble) {
      parsedValue = double.parse(newValue) as T;
    } else {
      parsedValue = int.parse(newValue) as T;
    }
    await updateSettingValue(
      ref: ref,
      provider: provider,
      key: key,
      value: parsedValue,
    );
  } catch (_) {
    // パース失敗時はデフォルト値を使用
    await updateSettingValue(
      ref: ref,
      provider: provider,
      key: key,
      value: defaultValue,
    );
  }
}

/// Radio設定の変更時に使用する関数
Future<void> updateRadioSetting<T>({
  required WidgetRef ref,
  required StateProvider<T> provider,
  required String key,
  required T value,
}) async {
  return updateSettingValue(
    ref: ref,
    provider: provider,
    key: key,
    value: value,
  );
}

/// 全ての設定値をSharedPreferencesから読み込む
Future<void> loadSettingsFromPrefs(WidgetRef ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // すべての設定値の読み込みをnull許容にして、デフォルト値をフォールバックとして使用
    final ttsSpeed = prefs.getDouble('tts_speed') ?? AppConstants.ttsSpeedInit;
    ref.read(ttsSpeedProvider.notifier).state = ttsSpeed;

    final ttsDuration =
        prefs.getDouble('tts_duration') ?? AppConstants.ttsDurationInit;
    ref.read(ttsDurationProvider.notifier).state = ttsDuration;

    final reachJudgeRadius =
        prefs.getInt('reach_judge_radius') ?? AppConstants.reachJudgeRadiusInit;
    ref.read(reachJudgeRadiusProvider.notifier).state = reachJudgeRadius;

    final reachNoticeNum =
        prefs.getInt('reach_notice_num') ?? AppConstants.reachNoticeNumInit;
    ref.read(reachNoticeNumProvider.notifier).state = reachNoticeNum;

    final markNameType =
        prefs.getInt('mark_name_type') ?? AppConstants.markNameTypeInit;
    ref.read(markNameTypeProvider.notifier).state = markNameType;

    // 設定読み込み完了をマーク
    ref.read(settingsLoadedProvider.notifier).state = true;
  } catch (e) {
    debugPrint('設定の読み込み中にエラーが発生しました: $e');
  }
}

/// 全ての設定値をデフォルト値にリセットする
Future<void> resetAllSettings(WidgetRef ref) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    // 全ての設定をデフォルト値に戻す
    await prefs.setDouble('tts_speed', AppConstants.ttsSpeedInit);
    await prefs.setDouble('tts_duration', AppConstants.ttsDurationInit);
    await prefs.setInt('reach_judge_radius', AppConstants.reachJudgeRadiusInit);
    await prefs.setInt('reach_notice_num', AppConstants.reachNoticeNumInit);
    await prefs.setInt('mark_name_type', AppConstants.markNameTypeInit);

    // Providerの値も更新
    ref.read(ttsSpeedProvider.notifier).state = AppConstants.ttsSpeedInit;
    ref.read(ttsDurationProvider.notifier).state = AppConstants.ttsDurationInit;
    ref.read(reachJudgeRadiusProvider.notifier).state =
        AppConstants.reachJudgeRadiusInit;
    ref.read(reachNoticeNumProvider.notifier).state =
        AppConstants.reachNoticeNumInit;
    ref.read(markNameTypeProvider.notifier).state =
        AppConstants.markNameTypeInit;
  } catch (e) {
    debugPrint('設定のリセット中にエラーが発生しました: $e');
  }
}

// 現在の設定値を確認するためのヘルパー関数
Map<String, dynamic> getCurrentSettings(WidgetRef ref) {
  return {
    'tts_speed': ref.read(ttsSpeedProvider),
    'tts_duration': ref.read(ttsDurationProvider),
    'reach_judge_radius': ref.read(reachJudgeRadiusProvider),
    'reach_notice_num': ref.read(reachNoticeNumProvider),
    'mark_name_type': ref.read(markNameTypeProvider),
    'settings_loaded': ref.read(settingsLoadedProvider),
  };
}
