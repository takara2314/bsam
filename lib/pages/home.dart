import 'package:flutter/material.dart';

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
        title: SizedBox(
          width: width * 0.8,
          child: Text(
            'セーリング団体名',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold
            )
          ),
        ),
        centerTitle: true
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            const Text('選手を選択'),
            DropdownButton(
              items: [
                for (final user in users)
                  DropdownMenuItem(
                    value: user.id!,
                    child: Text(user.displayName!),
                  )
              ],
              onChanged: _changeUser,
              value: _userId,
            ),
            ElevatedButton(
              child: const Text(
                'レースを始める'
              ),
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
            )
          ]
        )
      )
    );
  }
}
