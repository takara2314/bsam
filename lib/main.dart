import 'package:bsam/router.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

const apiServerBaseUrl = 'https://stg.api.bsam.app';
const authServerBaseUrl = 'https://stg.auth.bsam.app';
const gameServerBaseUrlWs = 'wss://stg.game.bsam.app';

const bodyTextSize = 16.0;
const bodyHeadingSize = 20.0;

const bodyTextColor = Color.fromARGB(255, 62, 62, 62);
const primaryColor = Color.fromARGB(255, 0, 42, 149);
const secondaryColor = Color.fromARGB(255, 79, 150, 255);

void main() {
  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'B-SAM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        scaffoldBackgroundColor: const Color.fromARGB(255, 242, 242, 242),
        useMaterial3: true,
      ),
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
    );
  }
}
