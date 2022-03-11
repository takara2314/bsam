import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/androidId.dart';
import 'package:sailing_assist_mie/providers/deviceName.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';

class Home extends HookConsumerWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocationAllowed = useState<bool>(false);
    final androidId = ref.watch(androidIdProvider.notifier);
    final deviceName = ref.watch(deviceNameProvider.notifier);

    useEffect(() {
      () async {
        var status = await Permission.location.status;

        if (status == PermissionStatus.denied) {
          status = await Permission.location.request();
        }

        isLocationAllowed.value = status.isGranted;

        DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        androidId.state = androidInfo.androidId.toString();
        deviceName.state = androidInfo.brand.toString();
      }();
    }, const []);

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
                    onPressed: () => context.go('/races'),
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
                    onPressed: () => context.go('/simulate'),
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
                    onPressed: () => context.go('/settings')
                  ),
                  Visibility(
                    visible: !isLocationAllowed.value,
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
