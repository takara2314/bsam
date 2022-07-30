import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsam/pages/navi.dart';
import 'package:bsam/providers.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  static const jwts = {
    'e85c3e4d-21d8-4c42-be90-b79418419c40': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkwMTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiJlODVjM2U0ZC0yMWQ4LTRjNDItYmU5MC1iNzk0MTg0MTljNDAifQ.y5slXKFQg-v7-OQMmJStH-3VucTlpyfKiZn1KNw0QU8',
    '925aea83-44e0-4ff3-9ce6-84a1c5190532': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkwMzIsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI5MjVhZWE4My00NGUwLTRmZjMtOWNlNi04NGExYzUxOTA1MzIifQ.Y0kuwnACMKQTaidznWCCFDxu5HufcQ8kBtBIbo5ZDMM',
    '4aaee190-e8ef-4fb6-8ee9-510902b68cf4': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NjY5MTkwNTMsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI0YWFlZTE5MC1lOGVmLTRmYjYtOGVlOS01MTA5MDJiNjhjZjQifQ.N33chJ61bl8pV5GN3-u3WbN99D4rQ59iVIZJtMoPVrs'
  };

  static const raceId = '3ae8c214-eb72-481c-b110-8e8f32ecf02d';

  String? _userName;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
      }
    }();
  }

  _changeUser(String? value) {
      final userId = ref.read(userIdProvider.notifier);
      final jwt = ref.read(jwtProvider.notifier);

      userId.state = value;
      jwt.state = jwts[value];

      setState(() {
        _userName = value;
      });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    final userId = ref.watch(userIdProvider);
    final jwt = ref.watch(jwtProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ゴーリキテスト',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold
          )
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('ユーザー'),
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 'e85c3e4d-21d8-4c42-be90-b79418419c40',
                  child: Text('テストくんA'),
                ),
                DropdownMenuItem(
                  value: '925aea83-44e0-4ff3-9ce6-84a1c5190532',
                  child: Text('テストくんB'),
                ),
                DropdownMenuItem(
                  value: '4aaee190-e8ef-4fb6-8ee9-510902b68cf4',
                  child: Text('テストくんC'),
                ),
              ],
              onChanged: _changeUser,
              value: _userName,
            ),
            ElevatedButton(
              child: const Text(
                'レースを始める'
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => Navi(raceId: raceId),
                  )
                );
              }
            ),
          ]
        )
      )
    );
  }
}
