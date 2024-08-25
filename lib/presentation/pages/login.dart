import 'package:bsam/main.dart';
import 'package:bsam/presentation/widgets/icon.dart';
import 'package:bsam/presentation/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LoginPage extends HookConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final associationId = useState('');
    final password = useState('');

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Introduction(),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.white,
              width: double.infinity,
              height: 300,
            ),
          ),
        ],
      )
    );
  }
}

class Introduction extends StatelessWidget {
  const Introduction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.only(top: 100, left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: const AppIcon(
              size: 100
            )
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Heading(
                  'セーリングを',
                  fontSize: 28,
                  color: primaryColor
                ),
                Heading(
                  'すべての人に。',
                  fontSize: 28,
                  color: primaryColor
                ),
                Heading(
                  '私がマークまで安全に',
                  fontSize: 28
                ),
                Heading(
                  'ナビゲーションします。',
                  fontSize: 28
                )
              ]
            )
          ),
        ]
      )
    );
  }
}
