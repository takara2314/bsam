import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';
import 'package:bsam/pages/home/page.dart';
import 'package:bsam/providers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:bsam/constants/app_constants.dart';

const primaryColor = Color.fromRGBO(0, 42, 149, 1);

void main() async {
  // クラッシュハンドラ
  runZonedGuarded<Future<void>>(() async {
    // 環境変数ファイルの読み込み
    await dotenv.load(fileName: '.env');

    // Firebaseの初期化
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // ロケールデータの初期化を追加
    await initializeDateFormatting('ja_JP');

    // クラッシュハンドラ (Flutterフレームワーク内でスローされたすべてのエラー)
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    WidgetsFlutterBinding.ensureInitialized();
    // 画面の向きを縦に固定
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    runApp(const ProviderScope(child: App()));
  },
    // クラッシュハンドラ (Flutterフレームワーク内でキャッチされないエラー)
    (error, stack) =>
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)
  );
}

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _showingNoConnectionDialog = false;

  @override
  void initState() {
    super.initState();
    loadSettingsFromPrefs(ref);
    _initConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _initConnectivity() async {
    late List<ConnectivityResult> result;
    try {
      result = await Connectivity().checkConnectivity();
    } catch (e) {
      debugPrint('Connectivity check failed: ${e.toString()}');
      result = [ConnectivityResult.none];
    }

    // Providerの状態を更新（リストの最初の接続タイプを使用）
    if (result.isNotEmpty) {
      ref.read(connectivityProvider.notifier).state = result.first;
    } else {
      ref.read(connectivityProvider.notifier).state = ConnectivityResult.none;
    }
  }

  void _setupConnectivityListener() {
    // ★★★ リスナー設定直後に現在の接続状態を確認してダイアログ表示を判断 ★★★
    final initialConnectivity = ref.read(connectivityProvider);
    if (initialConnectivity == ConnectivityResult.none) {
       _showNoConnectionDialog();
    }

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      ConnectivityResult currentResult;
      // Providerの状態を更新（リストの最初の接続タイプを使用）
      if (results.isNotEmpty) {
        currentResult = results.first;
        ref.read(connectivityProvider.notifier).state = currentResult;
      } else {
        currentResult = ConnectivityResult.none;
        ref.read(connectivityProvider.notifier).state = currentResult;
      }

      // 接続がない場合またはリストが空の場合はダイアログを表示
      if (currentResult == ConnectivityResult.none) {
        _showNoConnectionDialog();
      } else {
        // 接続が復活した場合、表示中のダイアログを閉じる
        if (_showingNoConnectionDialog && _navigatorKey.currentState != null) {
          Navigator.of(_navigatorKey.currentContext!, rootNavigator: true).pop();
          _showingNoConnectionDialog = false;
        }
      }
    });
  }

  void _showNoConnectionDialog() {
    // 既にダイアログが表示されている場合は何もしない
    if (_showingNoConnectionDialog) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_navigatorKey.currentContext != null) {
        _showingNoConnectionDialog = true;
        showDialog(
          context: _navigatorKey.currentContext!,
          barrierDismissible: false, // ダイアログ外をタップしても閉じない
          builder: (context) => AlertDialog(
            title: const Text(AppConstants.noConnectionDialogTitle),
            content: const Text(AppConstants.noConnectionDialogContent),
            backgroundColor: Colors.white,
            icon: const Icon(Icons.signal_wifi_off, color: Colors.red, size: 36),
            actions: [
              TextButton(
                onPressed: () {
                  _showingNoConnectionDialog = false;
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-SAM',
      scaffoldMessengerKey: _scaffoldMessengerKey,
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: primaryColor,
        scaffoldBackgroundColor: const Color(0xFFF2F2F2),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.transparent),
          backgroundColor: Colors.transparent,
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary
          ),
          displayMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          displaySmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          headlineMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold
          ),
          headlineSmall: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
          titleLarge: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold
          ),
          bodyLarge: const TextStyle(
            fontSize: 18
          ),
          bodyMedium: const TextStyle(
            fontSize: 16
          ),
          labelLarge: const TextStyle(
            fontSize: 14
          ),
          bodySmall: const TextStyle(
            fontSize: 12
          ),
          labelSmall: const TextStyle(
            fontSize: 10
          )
        )
      ),
      home: const Home()
    );
  }
}
