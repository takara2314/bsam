import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bsam/models/user.dart';
import 'package:bsam/providers.dart';
import 'package:bsam/pages/home/app_bar.dart';
import 'package:bsam/pages/home/athlete_select.dart';
import 'package:bsam/pages/home/participate_button.dart';
import 'package:bsam/pages/home/race_name_area.dart';
import 'package:bsam/pages/home/settings.dart';
import 'package:bsam/constants/app_constants.dart';

class Home extends ConsumerStatefulWidget {
  const Home({super.key});

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

  String? _assocId;
  String? _userId;
  double _ttsSpeed = AppConstants.ttsSpeedInit;
  double _ttsDuration = AppConstants.ttsDurationInit;
  int _reachJudgeRadius = AppConstants.reachJudgeRadiusInit;
  int _reachNoticeNum = AppConstants.reachNoticeNumInit;
  final double _headingFix = AppConstants.headingFixInit;
  final bool _isAnnounceNeighbors = false;
  int _markNameType = AppConstants.markNameTypeInit;
  String _version = '';

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
      _loadVersion();
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

  _changeTtsSpeedAtTextForm(String value) {
    try {
      setState(() {
        _ttsSpeed = double.parse(value);
      });
    } catch (_) {
      setState(() {
        _ttsSpeed = AppConstants.ttsSpeedInit;
      });
    }
  }

  _changeTtsDurationAtTextForm(String value) {
    try {
      setState(() {
        _ttsDuration = double.parse(value);
      });
    } catch (_) {
      setState(() {
        _ttsDuration = AppConstants.ttsDurationInit;
      });
    }
  }

  _changeReachJudgeRadiusAtTextForm(String value) {
    try {
      setState(() {
        _reachJudgeRadius = int.parse(value);
      });
    } catch (_) {
      setState(() {
        _reachJudgeRadius = AppConstants.reachJudgeRadiusInit;
      });
    }
  }

  _changeReachNoticeNumAtTextForm(String value) {
    try {
      setState(() {
        _reachNoticeNum = int.parse(value);
      });
    } catch (_) {
      setState(() {
        _reachNoticeNum = AppConstants.reachNoticeNumInit;
      });
    }
  }

  _changeMarkNameType(int value) {
    setState(() {
      _markNameType = value;
    });
  }

  _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(
        assocName: AppConstants.assocName
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              AthleteSelect(
                users: users,
                userId: _userId,
                changeUser: _changeUser
              ),
              const RaceNameArea(
                raceName: AppConstants.raceName
              ),
              ParticipateButton(
                assocId: _assocId,
                userId: _userId,
                ttsSpeed: _ttsSpeed,
                ttsDuration: _ttsDuration,
                reachJudgeRadius: _reachJudgeRadius,
                reachNoticeNum: _reachNoticeNum,
                headingFix: _headingFix,
                isAnnounceNeighbors: _isAnnounceNeighbors,
                markNameType: _markNameType
              ),
              Settings(
                ttsSpeed: _ttsSpeed,
                ttsSpeedInit: AppConstants.ttsSpeedInit,
                changeTtsSpeedAtTextForm: _changeTtsSpeedAtTextForm,
                ttsDuration: _ttsDuration,
                ttsDurationInit: AppConstants.ttsDurationInit,
                changeTtsDurationAtTextForm: _changeTtsDurationAtTextForm,
                reachJudgeRadius: _reachJudgeRadius,
                reachJudgeRadiusInit: AppConstants.reachJudgeRadiusInit,
                changeReachJudgeRadiusAtTextForm: _changeReachJudgeRadiusAtTextForm,
                reachNoticeNum: _reachNoticeNum,
                reachNoticeNumInit: AppConstants.reachNoticeNumInit,
                changeReachNoticeNumAtTextForm: _changeReachNoticeNumAtTextForm,
                markNameType: _markNameType,
                changeMarkNameType: _changeMarkNameType
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 50),
                child: Text(
                  'アプリバージョン: $_version',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey
                  ),
                ),
              ),
            ]
          )
        )
      )
    );
  }
}
