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

  String? _raceName;
  String? _userName;
  double _ttsSpeed = 1.0;
  double _ttsDuration = 3.0;
  bool _isAnnounceNeighbors = false;

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

  _changeRace(String? value) {
    setState(() {
      _raceName = value;
    });
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

  _changeDegFix(String value) {
    final degFix = ref.read(degFixProvider.notifier);
    try {
      degFix.state = double.parse(value);
    } catch (_) {
      degFix.state = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final degFix = ref.watch(degFixProvider);

    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          width: width * 0.8,
          child: DropdownButton(
            items: const [
              DropdownMenuItem(
                value: 'e85c3e4d-21d8-4c42-be9',
                child: Text('ゴーリキテスト'),
              ),
              DropdownMenuItem(
                value: '925aea83-44e0-4ff3-9ce6',
                child: Text('ハマグチテスト'),
              ),
              DropdownMenuItem(
                value: 'hogemaru',
                child: Text('鳥羽商船テスト'),
              ),
            ],
            onChanged: _changeRace,
            value: _raceName,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            )
          )
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            // SizedBox(
            //   width: width * 0.9,
            //   child: ElevatedButton(
            //     child: Center(
            //       child: Text(
            //         'テストくん',
            //         style: TextStyle(
            //           color: Theme.of(context).colorScheme.inverseSurface,
            //           fontWeight: FontWeight.bold
            //         )
            //       ),
            //     ),
            //     onPressed: () {},
            //     style: ButtonStyle(
            //       gradient: MaterialStateProperty.all(
            //         LinearGradient(
            //           colors: [
            //             Theme.of(context).colorScheme.primary,
            //             Theme.of(context).colorScheme.secondary
            //           ]
            //         )
            //       )
            //     )
            //     // style: ElevatedButton.styleFrom(
            //     //   primary: Theme.of(context).colorScheme.primaryContainer,
            //     //   shape: RoundedRectangleBorder(
            //     //     borderRadius: BorderRadius.circular(10.0)
            //     //   ),
            //     //   minimumSize: Size(width * 0.8, height * 0.1)
            //     // )
            //   )
            // ),
            const Text('ユーザー'),
            DropdownButton(
              items: const [
                DropdownMenuItem(
                  value: 'e85c3e4d-21d8-4c42-be90-b79418419c40',
                  child: Text('テストくんA')
                ),
                DropdownMenuItem(
                  value: '925aea83-44e0-4ff3-9ce6-84a1c5190532',
                  child: Text('テストくんB')
                ),
                DropdownMenuItem(
                  value: '4aaee190-e8ef-4fb6-8ee9-510902b68cf4',
                  child: Text('テストくんC')
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
                    builder: (context) => Navi(
                      raceId: raceId,
                      ttsSpeed: _ttsSpeed,
                      ttsDuration: _ttsDuration,
                      isAnnounceNeighbors: _isAnnounceNeighbors
                    ),
                  )
                );
              }
            ),
            SizedBox(
              width: width * 0.9,
              child: TextFormField(
                initialValue: degFix.toString(),
                onChanged: _changeDegFix,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '補正角度 [deg]',
                ),
              )
            ),
            SizedBox(
              width: width * 0.9,
              child: TextFormField(
                initialValue: _ttsSpeed.toString(),
                onChanged: (String value) {
                  try {
                    setState(() {
                      _ttsSpeed = double.parse(value);
                    });
                  } catch (_) {
                    setState(() {
                      _ttsSpeed = 1.0;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'アナウンス速度',
                ),
              )
            ),
            SizedBox(
              width: width * 0.9,
              child: TextFormField(
                initialValue: _ttsDuration.toString(),
                onChanged: (String value) {
                  try {
                    setState(() {
                      _ttsDuration = double.parse(value);
                    });
                  } catch (_) {
                    setState(() {
                      _ttsDuration = 3.0;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'アナウンス間隔 [秒]',
                ),
              )
            ),
            Row(
              children: [
                const Text('近くのセイルをお知らせする'),
                Switch(
                  value: _isAnnounceNeighbors,
                  onChanged: (bool value) {
                    setState(() {
                      _isAnnounceNeighbors = value;
                    });
                  }
                )
              ]
            )
          ]
        )
      )
    );
  }
}
