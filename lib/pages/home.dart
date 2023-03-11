import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:bsam/pages/navi.dart';
import 'package:bsam/models/user.dart';
import 'package:bsam/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  static final users = <User>[
    User(displayName: '1番艇', id: 'athlete1'),
    User(displayName: '2番艇', id: 'athlete2'),
    User(displayName: '3番艇', id: 'athlete3'),
    User(displayName: '4番艇', id: 'athlete4'),
    User(displayName: '5番艇', id: 'athlete5'),
    User(displayName: '6番艇', id: 'athlete6'),
    User(displayName: '7番艇', id: 'athlete7'),
    User(displayName: '8番艇', id: 'athlete8'),
    User(displayName: '9番艇', id: 'athlete9'),
    User(displayName: '10番艇', id: 'athlete10')
  ];

  static double ttsSpeedInit = 1.5;
  static double ttsDurationInit = 1.0;
  static double headingFixInit = 0.0;

  String? _assocId;
  String? _userId;
  double _ttsSpeed = ttsSpeedInit;
  double _ttsDuration = ttsDurationInit;
  double _headingFix = headingFixInit;
  final bool _isAnnounceNeighbors = false;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
      }

      _loadServerURL();
      _loadWavenetToken();
      _loadAssocInfo();
      _loadUserInfo();
    }();
  }

  _loadServerURL() {
    final String? url = dotenv.maybeGet('BSAM_SERVER_URL');

    final provider = ref.read(serverUrlProvider.notifier);
    provider.state = url;
  }

  _loadWavenetToken() {
    final String? token = dotenv.maybeGet('WAVENET_TOKEN');

    final provider = ref.read(wavenetTokenProvider.notifier);
    provider.state = token;
  }

  _loadAssocInfo() {
    final String? token = dotenv.maybeGet('BSAM_SERVER_TOKEN');
    Map<String, dynamic> payload = Jwt.parseJwt(token!);
    final String? id = payload['association_id'];

    final assocId = ref.read(assocIdProvider.notifier);
    final jwt = ref.read(jwtProvider.notifier);

    assocId.state = id;
    jwt.state = token;

    setState(() {
      _assocId = id;
    });
  }

  _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('user_id');

    if (id != null) {
      _setUserId(id);
    }
  }

  _setUserId(String id) {
    final userId = ref.read(userIdProvider.notifier);

    userId.state = id;

    setState(() {
      _userId = id;
    });
  }

  _storeUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('user_id', id);
  }

  _changeUser(String? value) {
    final id = value!;

    _setUserId(id);
    _storeUserId(id);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SvgPicture.asset(
              'images/logo.svg',
              semanticsLabel: 'logo',
              width: 42,
              height: 42
            ),
            Container(
              width: width * 0.6,
              padding: const EdgeInsets.only(left: 10, right: 10, top: 8, bottom: 8),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999)
              ),
              child: Text(
                'セーリング団体名',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                )
              )
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              iconSize: 32,
              onPressed: () {}
            )
          ]
        )
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                width: width * 0.9,
                margin: const EdgeInsets.only(top: 20, bottom: 30),
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: width * 0.4,
                      child: Column(
                        children: [
                          for (final user in users.sublist(0, users.length ~/ 2))
                            RadioListTile(
                              title: Text(user.displayName!),
                              value: user.id!,
                              groupValue: _userId,
                              onChanged: _changeUser,
                            )
                        ]
                      )
                    ),
                    SizedBox(
                      width: width * 0.4,
                      child: Column(
                        children: [
                          for (final user in users.sublist(users.length ~/ 2))
                            RadioListTile(
                              title: Text(user.displayName!),
                              value: user.id!,
                              groupValue: _userId,
                              onChanged: _changeUser,
                            )
                        ]
                      )
                    ),
                  ]
                )
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text('テストレース2023')
              ),
              SizedBox(
                width: width * 0.9,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Navi(
                          assocId: _assocId!,
                          userId: _userId!,
                          ttsSpeed: _ttsSpeed,
                          ttsDuration: _ttsDuration,
                          headingFix: _headingFix,
                          isAnnounceNeighbors: _isAnnounceNeighbors
                        ),
                      )
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    padding: const EdgeInsets.only(top: 20, bottom: 20)
                  ),
                  child: const Text(
                    'レースに参加する',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                    )
                  )
                ),
              ),
              Container(
                width: width * 0.9,
                margin: const EdgeInsets.only(top: 20, bottom: 20),
                child: Table(
                  children: <TableRow>[
                    TableRow(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          alignment: Alignment.centerLeft,
                          child: const Text('アナウンス速度')
                        ),
                        TextFormField(
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
                          textAlign: TextAlign.center,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            // border-radius (not border line)
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10.0)),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                          ),
                        ),
                      ]
                    ),
                  ],
                ),
              ),

              // SizedBox(
              //   width: width * 0.9,
              //   child: TextFormField(
              //     initialValue: ttsDurationInit.toString(),
              //     onChanged: (String value) {
              //       try {
              //         setState(() {
              //           _ttsDuration = double.parse(value);
              //         });
              //       } catch (_) {
              //         setState(() {
              //           _ttsDuration = ttsDurationInit;
              //         });
              //       }
              //     },
              //     decoration: const InputDecoration(
              //       border: UnderlineInputBorder(),
              //       labelText: 'アナウンス間隔 [秒]',
              //     ),
              //   )
              // ),
              // SizedBox(
              //   width: width * 0.9,
              //   child: TextFormField(
              //     initialValue: headingFixInit.toString(),
              //     onChanged: (String value) {
              //       try {
              //         setState(() {
              //           _headingFix = double.parse(value);
              //         });
              //       } catch (_) {
              //         setState(() {
              //           _headingFix = headingFixInit;
              //         });
              //       }
              //     },
              //     decoration: const InputDecoration(
              //       border: UnderlineInputBorder(),
              //       labelText: '補正角度 [deg]',
              //     ),
              //   )
              // )
            ]
          )
        )
      )
    );
  }
}
