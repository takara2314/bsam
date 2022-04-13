import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sailing_assist_mie/pages/races/select.dart' as races;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home> {
  bool _isAllowedLocation = false;

  @override
  void initState() {
    super.initState();

    () async {
      PermissionStatus permLocation = await Permission.location.status;

      if (permLocation == PermissionStatus.denied) {
        permLocation = await Permission.location.request();
        setState(() {
          _isAllowedLocation = permLocation != PermissionStatus.denied;
        });

      } else {
        setState(() {
          _isAllowedLocation = true;
        });
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
              child: const Logo(),
              margin: const EdgeInsets.only(top: 70, bottom: 70)
            ),
            SizedBox(
              child: Column(
                children: [
                  ElevatedButton(
                    child: const Text(
                      'レースする',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w500
                      )
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const races.Select(),
                        )
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(0, 98, 104, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      minimumSize: const Size(280, 60)
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
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const Simulation(),
                      //   )
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      primary: const Color.fromRGBO(232, 232, 232, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)
                      ),
                      padding: const EdgeInsets.all(8),
                      minimumSize: const Size(280, 60)
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
                    onPressed: () {
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => const Settings(),
                      //   )
                      // );
                    }
                  ),
                  Visibility(
                    visible: !_isAllowedLocation,
                    child: const Text(
                      '位置情報が有効になっていません！',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold
                      )
                    )
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
              height: 200
            )
          ]
        )
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'Sailing',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 42, 149, 1),
            fontSize: 60
          )
        ),
        Text(
          'Assist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 42, 149, 1),
            fontSize: 60
          )
        ),
        Text(
          'Mie',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 42, 149, 1),
            fontSize: 60
          )
        )
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }
}
