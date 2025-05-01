import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:bsam/providers.dart';
import 'package:bsam/constants/app_constants.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  String _version = '';
  DateTime? _jwtExpiryDate;
  bool _isLicenseActive = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
    _checkJwtExpiry();
    loadSettingsFromPrefs(ref);
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
      });
    }
  }

  void _checkJwtExpiry() {
    final jwtToken = ref.read(jwtProvider);
    if (jwtToken != null) {
      try {
        Map<String, dynamic> payload = Jwt.parseJwt(jwtToken);
        if (payload.containsKey('exp')) {
          final expiryTimestamp = payload['exp'] * 1000;
          _jwtExpiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
          _isLicenseActive = DateTime.now().isBefore(_jwtExpiryDate!);
          setState(() {});
        }
      } catch (e) {
        _isLicenseActive = false;
         setState(() {});
      }
    } else {
       _isLicenseActive = false;
       setState(() {});
    }
  }

  Future<void> _resetSettings() async {
    await resetAllSettings(ref);
  }

  Future<void> _showResetConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // ユーザーはダイアログ外をタップして閉じられない
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('設定のリセット'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('すべての設定を初期値に戻しますか？'),
                Text('この操作は元に戻せません。'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('リセット'),
              onPressed: () async {
                // await の前に Navigator と ScaffoldMessenger を取得
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                // mounted の状態も await 前に確認
                final isMounted = mounted;

                await _resetSettings();

                // await の後に mounted の状態を確認し、取得済みの変数を使用
                if (isMounted) {
                  navigator.pop();
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(content: Text('設定をリセットしました。')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedExpiryDate = _jwtExpiryDate != null
        ? DateFormat('yyyy年M月d日', 'ja_JP').format(_jwtExpiryDate!)
        : '不明';

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: <Widget>[
          // --- App Info Section ---
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SvgPicture.asset(
                    'images/logo.svg',
                    semanticsLabel: 'B-SAM Logo',
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'B-SAM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('バージョン: $_version'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // --- License Info Section ---
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text(
                     'ライセンス情報',
                     style: TextStyle(
                       fontSize: 16,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        _isLicenseActive ? Icons.check_circle : Icons.cancel,
                        color: _isLicenseActive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isLicenseActive ? 'ライセンスは有効です' : 'ライセンスは無効です',
                        style: TextStyle(
                          color: _isLicenseActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                   if (_jwtExpiryDate != null) ...[
                     const SizedBox(height: 5),
                     Row(
                       children: [
                         Text('有効期限: $formattedExpiryDate'),
                         if (!_isLicenseActive)
                           const Text(
                             '（有効期限切れ）',
                             style: TextStyle(color: Colors.red),
                           ),
                       ],
                     ),
                  ] else if (!_isLicenseActive) ... [
                     const SizedBox(height: 5),
                     const Text('有効なライセンスが設定されていません。'),
                  ]

                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // --- Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'アナウンス設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildSliderSetting(
                  label: 'アナウンス速度',
                  provider: ttsSpeedProvider,
                  min: 0.0,
                  max: 1.0,
                  divisions: 10,
                  prefsKey: 'tts_speed',
                ),
                _buildTextFormSetting(
                  label: 'アナウンス間隔 [秒]',
                  provider: ttsDurationProvider,
                  prefsKey: 'tts_duration',
                  defaultValue: AppConstants.ttsDurationInit,
                  isDouble: true,
                ),
                const SizedBox(height: 30),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'ナビゲーション設定',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildTextFormSetting(
                  label: '到達判定半径 [m]',
                  provider: reachJudgeRadiusProvider,
                  prefsKey: 'reach_judge_radius',
                  defaultValue: AppConstants.reachJudgeRadiusInit,
                ),
                 _buildTextFormSetting(
                  label: '到着通知回数',
                  provider: reachNoticeNumProvider,
                  prefsKey: 'reach_notice_num',
                  defaultValue: AppConstants.reachNoticeNumInit,
                ),
                _buildRadioSetting(
                  label: 'マーク名称',
                  provider: markNameTypeProvider,
                  options: {0: 'マーク名 (上、サイド、下)', 1: '番号 (1、2、3)'},
                  prefsKey: 'mark_name_type',
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: _showResetConfirmationDialog,
              child: const Text(
                '設定をリセット',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 設定項目ウィジェットのヘルパーメソッド

  Widget _buildSliderSetting({
    required String label,
    required StateProvider<double> provider,
    required double min,
    required double max,
    required int divisions,
    required String prefsKey,
  }) {
    final value = ref.watch(provider);
    return ListTile(
      title: Text(label),
      subtitle: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: value.toStringAsFixed(1),
        onChanged: (newValue) {
          ref.read(provider.notifier).state = newValue;
        },
        onChangeEnd: (newValue) async {
          // 共通関数を使用して設定を保存
          await updateSliderSetting(
            ref: ref,
            provider: provider,
            key: prefsKey,
            value: newValue
          );
        },
      ),
      trailing: Text(
        value.toStringAsFixed(1),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextFormSetting<T extends num>({
    required String label,
    required StateProvider<T> provider,
    required String prefsKey,
    required T defaultValue,
    bool isDouble = false,
  }) {
    // TextEditingController を使用して状態を管理
    final controller = TextEditingController(text: ref.watch(provider).toString());

    return ListTile(
      title: Text(label),
      subtitle: TextFormField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
        decoration: InputDecoration(
          hintText: defaultValue.toString(),
        ),
        onFieldSubmitted: (newValue) async {
          // 共通関数を使用して設定を保存
          await updateTextFormSetting(
            ref: ref,
            provider: provider,
            key: prefsKey,
            newValue: newValue,
            defaultValue: defaultValue,
            isDouble: isDouble
          );
          // 更新後の値をコントローラーに反映（パースエラー時も正しく表示される）
          controller.text = ref.read(provider).toString();
        },
      ),
    );
  }

  Widget _buildRadioSetting<T>({
    required String label,
    required StateProvider<T> provider,
    required Map<T, String> options,
    required String prefsKey,
  }) {
    final selectedValue = ref.watch(provider);
    return ListTile(
      title: Text(label),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: options.entries.map((entry) {
          return RadioListTile<T>(
            title: Text(entry.value),
            value: entry.key,
            groupValue: selectedValue,
            onChanged: (T? newValue) async {
              if (newValue != null) {
                // 共通関数を使用して設定を保存
                await updateRadioSetting(
                  ref: ref,
                  provider: provider,
                  key: prefsKey,
                  value: newValue
                );
              }
            },
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ),
    );
  }
}
