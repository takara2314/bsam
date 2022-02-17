import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              child: Column(
                children: const [
                  Text(
                    'Sailing',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 72
                    )
                  ),
                  Text(
                    'Assist',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 72
                    )
                  ),
                  Text(
                    'Mie',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(0, 42, 149, 1),
                      fontSize: 72
                    )
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              margin: const EdgeInsets.only(top: 80, bottom: 150)
            ),
            SizedBox(
              child: Column(
                children: [
                  ElevatedButton(
                    child: const Text(
                      'レースする',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () => context.go('/select-race'),
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0, 98, 104, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      minimumSize: const Size(300, 60)
                    )
                  ),
                  ElevatedButton(
                    child: const Text(
                      'シミュレーションする',
                      style: TextStyle(
                        color: Color.fromRGBO(50, 50, 50, 1),
                        fontSize: 22,
                        fontWeight: FontWeight.w500
                      ),
                    ),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(232, 232, 232, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(300, 60)
                    )
                  ),
                  TextButton(
                    child: const Text(
                      '設定する',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () {}
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              height: 200
            )
          ]
        )
      )
    );
  }
}
