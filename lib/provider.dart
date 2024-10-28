import 'package:hooks_riverpod/hooks_riverpod.dart';

const tokenInitValue = '';
const ttsSpeedInitValue = 0.7;

final tokenProvider = StateProvider((ref) => tokenInitValue);
final ttsSpeedProvider = StateProvider((ref) => ttsSpeedInitValue);
