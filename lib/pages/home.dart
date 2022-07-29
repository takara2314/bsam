import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bsam/providers.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  ConsumerState<Home> createState() => _Home();
}

class _Home extends ConsumerState<Home> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            Container(
              child: Text('濱口さん'),
              margin: EdgeInsets.only(top: 50, bottom: 50),
              width: width * 0.9,
              height: 200,
              decoration: BoxDecoration(color: Colors.lime),
            ),
            DropdownButton(
              value: 'USA',
              items: const [
                DropdownMenuItem(child: Text("USA"), value: "USA"),
                DropdownMenuItem(child: Text("Canada"), value: "Canada"),
                DropdownMenuItem(child: Text("Brazil"), value: "Brazil"),
                DropdownMenuItem(child: Text("England"), value: "England"),
              ],
              onChanged: (String? text) {}
            ),
            OutlinedButton(onPressed: () {}, child: Text('レースを始める')),
            ElevatedButton(onPressed: () {}, child: Text('レースを始める')),
            TextButton(onPressed: () {}, child: Text('レースを始める')),
          ]
        )
      )
    );
  }
}
