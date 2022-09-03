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
    'e85c3e4d-21d8-4c42-be90-b79418419c40': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiJlODVjM2U0ZC0yMWQ4LTRjNDItYmU5MC1iNzk0MTg0MTljNDAifQ.EXNYO2RGJRN-eo3mt-5JQ7HksRU-q1VlGO6dOWdVcds',
    '925aea83-44e0-4ff3-9ce6-84a1c5190532': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI5MjVhZWE4My00NGUwLTRmZjMtOWNlNi04NGExYzUxOTA1MzIifQ.FpUB9byHyYNNjYNA685zmpnKxI0z3L1TY1yQyxxrqU8',
    '4aaee190-e8ef-4fb6-8ee9-510902b68cf4': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI0YWFlZTE5MC1lOGVmLTRmYjYtOGVlOS01MTA5MDJiNjhjZjQifQ.a_7gOFmaPRmYY8Z1wKNWJkrAsw6IBe9Kj5P64dT1e0s',
    'd6e367e6-c630-410f-bcc7-de02da21dd3a': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiJkNmUzNjdlNi1jNjMwLTQxMGYtYmNjNy1kZTAyZGEyMWRkM2EifQ.y2XWFv6wKN64Hyh-R8p3d__95HakA0Yh9FFfCAqIolw',
    'f3f4da8f-6ab0-4f0e-90a9-2689d72d2a4f': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiJmM2Y0ZGE4Zi02YWIwLTRmMGUtOTBhOS0yNjg5ZDcyZDJhNGYifQ.jHf-OgvVthXEsC7nRA_A0-zm1XNEr7JXhbDSxtajgMs',
    '23d96555-5ff0-4c5d-8b03-2f1db89141f1': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiIyM2Q5NjU1NS01ZmYwLTRjNWQtOGIwMy0yZjFkYjg5MTQxZjEifQ.3_9w3_Pp2CHcxzfGo3saRM-hEp-aJFE4wjZsysPwcfk',
    'b0e968e9-8dd7-4e20-90a7-6c97834a4e88': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiJiMGU5NjhlOS04ZGQ3LTRlMjAtOTBhNy02Yzk3ODM0YTRlODgifQ.PVcMnCdwckwSH9CTrwuGsqMqdPPp7pr8Wp36Rsj_1dY',
    '605ded0a-ed1f-488b-b0ce-4ccf257c7329': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI2MDVkZWQwYS1lZDFmLTQ4OGItYjBjZS00Y2NmMjU3YzczMjkifQ.wl1VC8TCydNEn7YvoJUioDh30CoPkWMNo-_SMSKS1WI',
    '0e9737f7-6d62-447f-ad00-bd36c4532729': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiIwZTk3MzdmNy02ZDYyLTQ0N2YtYWQwMC1iZDM2YzQ1MzI3MjkifQ.cAt_Izqdw0FpXoqnbho8XFAtw0SeYvTZ30NqcwzC0Cc',
    '55072870-f00e-4ab9-bc6c-1710eef5b0a0': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2Njk5NTYwNTEsIm1hcmtfbm8iOi0xLCJyb2xlIjoiYXRobGV0ZSIsInVzZXJfaWQiOiI1NTA3Mjg3MC1mMDBlLTRhYjktYmM2Yy0xNzEwZWVmNWIwYTAifQ.6F2EJnuDh0FXmVaTVsoZr8eN3gARpptlg2VHYxbz2oA'
  };

  static const raceId = '3ae8c214-eb72-481c-b110-8e8f32ecf02d';

  static double ttsSpeedInit = 1.5;
  static double ttsDurationInit = 1.0;
  static double headingFixInit = 15.0;

  String? _raceName;
  String? _userName;
  double _ttsSpeed = ttsSpeedInit;
  double _ttsDuration = ttsDurationInit;
  double _headingFix = headingFixInit;
  bool _isAnnounceNeighbors = false;
  bool _isCalcHeadingFromGps = false;

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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

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
                DropdownMenuItem(
                  value: 'd6e367e6-c630-410f-bcc7-de02da21dd3a',
                  child: Text('テストくんD')
                ),
                DropdownMenuItem(
                  value: 'f3f4da8f-6ab0-4f0e-90a9-2689d72d2a4f',
                  child: Text('テストくんE')
                ),
                DropdownMenuItem(
                  value: '23d96555-5ff0-4c5d-8b03-2f1db89141f1',
                  child: Text('テストくんF')
                ),
                DropdownMenuItem(
                  value: 'b0e968e9-8dd7-4e20-90a7-6c97834a4e88',
                  child: Text('テストくんG')
                ),
                DropdownMenuItem(
                  value: '605ded0a-ed1f-488b-b0ce-4ccf257c7329',
                  child: Text('テストくんH')
                ),
                DropdownMenuItem(
                  value: '0e9737f7-6d62-447f-ad00-bd36c4532729',
                  child: Text('テストくんI')
                ),
                DropdownMenuItem(
                  value: '55072870-f00e-4ab9-bc6c-1710eef5b0a0',
                  child: Text('テストくんJ')
                )
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
                      headingFix: _headingFix,
                      isAnnounceNeighbors: _isAnnounceNeighbors,
                      isCalcHeadingFromGps: _isCalcHeadingFromGps,
                    ),
                  )
                );
              }
            ),
            SizedBox(
              width: width * 0.9,
              child: TextFormField(
                initialValue: ttsSpeedInit.toString(),
                onChanged: (String value) {
                  try {
                    setState(() {
                      _ttsSpeed = double.parse(value);
                    });
                  } catch (_) {
                    setState(() {
                      _ttsSpeed = ttsSpeedInit;
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
                initialValue: ttsDurationInit.toString(),
                onChanged: (String value) {
                  try {
                    setState(() {
                      _ttsDuration = double.parse(value);
                    });
                  } catch (_) {
                    setState(() {
                      _ttsDuration = ttsDurationInit;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'アナウンス間隔 [秒]',
                ),
              )
            ),
            SizedBox(
              width: width * 0.9,
              child: TextFormField(
                initialValue: headingFixInit.toString(),
                onChanged: (String value) {
                  try {
                    setState(() {
                      _headingFix = double.parse(value);
                    });
                  } catch (_) {
                    setState(() {
                      _headingFix = headingFixInit;
                    });
                  }
                },
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: '補正角度 [deg]',
                ),
              )
            ),
            Row(
              children: [
                const Text('過去の位置情報をもとに角度を計算'),
                Switch(
                  value: _isCalcHeadingFromGps,
                  onChanged: (bool value) {
                    setState(() {
                      _isCalcHeadingFromGps = value;
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
