import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailing_assist_mie/pages/home.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'B-SAM',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20
          ),
          centerTitle: false,
          iconTheme: IconThemeData(
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          elevation: 0,
          backgroundColor: Colors.transparent
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
      ),
      home: const Home()
    );
  }
}
