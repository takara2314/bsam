import 'package:bsam/provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> loadTtsSpeed(WidgetRef ref) async {
  final ttsSpeedNotifier = ref.watch(ttsSpeedProvider.notifier);

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final double? ttsSpeedInSharedPreferences = prefs.getDouble('ttsSpeed');

  if (ttsSpeedInSharedPreferences == null) {
    return;
  }

  ttsSpeedNotifier.state = ttsSpeedInSharedPreferences;
}

Future<void> saveTtsSpeed(WidgetRef ref, double ttsSpeed) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setDouble('ttsSpeed', ttsSpeed);

  final ttsSpeedNotifier = ref.watch(ttsSpeedProvider.notifier);
  ttsSpeedNotifier.state = ttsSpeed;
}

Future<void> deleteTtsSpeed(WidgetRef ref) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('ttsSpeed');

  final ttsSpeedNotifier = ref.watch(ttsSpeedProvider.notifier);
  ttsSpeedNotifier.state = ttsSpeedInitValue;
}

Future<void> debouncedSaveTtsSpeed(WidgetRef ref, double ttsSpeed) async {
  await Future.delayed(const Duration(milliseconds: 500));
  await saveTtsSpeed(ref, ttsSpeed);
}
