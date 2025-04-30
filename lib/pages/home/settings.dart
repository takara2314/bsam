import 'package:flutter/material.dart';

class Settings extends StatelessWidget {
  const Settings({
    super.key,
    required this.ttsSpeed,
    required this.ttsSpeedInit,
    required this.changeTtsSpeedAtTextForm,
    required this.ttsDuration,
    required this.ttsDurationInit,
    required this.changeTtsDurationAtTextForm,
    required this.reachJudgeRadius,
    required this.reachJudgeRadiusInit,
    required this.changeReachJudgeRadiusAtTextForm,
    required this.reachNoticeNum,
    required this.reachNoticeNumInit,
    required this.changeReachNoticeNumAtTextForm,
    required this.markNameType,
    required this.changeMarkNameType,
  });

  final double ttsSpeed;
  final double ttsSpeedInit;
  final Function(String) changeTtsSpeedAtTextForm;
  final double ttsDuration;
  final double ttsDurationInit;
  final Function(String) changeTtsDurationAtTextForm;
  final int reachJudgeRadius;
  final int reachJudgeRadiusInit;
  final Function(String) changeReachJudgeRadiusAtTextForm;
  final int reachNoticeNum;
  final int reachNoticeNumInit;
  final Function(String) changeReachNoticeNumAtTextForm;
  final int markNameType;
  final Function(int) changeMarkNameType;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
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
                onChanged: changeTtsSpeedAtTextForm,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                ),
              ),
            ]
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.centerLeft,
                child: const Text('アナウンス間隔 [秒]')
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  initialValue: ttsDurationInit.toString(),
                  onChanged: changeTtsDurationAtTextForm,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  ),
                ),
              ),
            ]
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.centerLeft,
                child: const Text('到達判定半径 [m]')
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  initialValue: reachJudgeRadiusInit.toString(),
                  onChanged: changeReachJudgeRadiusAtTextForm,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  ),
                ),
              ),
            ]
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.centerLeft,
                child: const Text('到達通知回数 [回]')
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: TextFormField(
                  initialValue: reachNoticeNumInit.toString(),
                  onChanged: changeReachNoticeNumAtTextForm,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.only(top: 8, bottom: 8, left: 10, right: 10),
                  ),
                ),
              ),
            ]
          ),
          TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20, bottom: 10),
                alignment: Alignment.centerLeft,
                child: const Text('マーク呼称')
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('上/下'),
                        value: 0,
                        groupValue: markNameType,
                        onChanged: (int? value) {
                          if (value != null) {
                            changeMarkNameType(value);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<int>(
                        title: const Text('数字'),
                        value: 1,
                        groupValue: markNameType,
                        onChanged: (int? value) {
                          if (value != null) {
                            changeMarkNameType(value);
                          }
                        },
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ),
            ]
          )
        ],
      ),
    );
  }
}
