import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class Simulate extends HookConsumerWidget {
  const Simulate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/')
        ),
        centerTitle: false,
        title: const Text(
          'シミュレーション',
          style: TextStyle(
            color: Colors.black
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent
      ),
      body: Container(
        child: const Text(
          '実装予定',
          style: TextStyle(
            fontSize: 24
          )
        ),
        margin: const EdgeInsets.only(top: 30, bottom: 30),
        alignment: Alignment.center,
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}
