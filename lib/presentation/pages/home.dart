import 'package:bsam/infrastructure/repository/token.dart';
import 'package:bsam/main.dart';
import 'package:bsam/presentation/widgets/icon.dart';
import 'package:bsam/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = useState(0);

    return Scaffold(
      appBar: HomeAppBar(
        associationName: 'エグサンポー協会',
        onPressedLogout: () => logoutDialogBuilder(context, ref),
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        // HookConsumer is a builder widget that allows you to read providers and utilise hooks.
        child: Text(
          '${counter.value}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          counter.value++;
          if (counter.value == 5) {
            context.push(racePagePath);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String associationName;
  final void Function() onPressedLogout;

  const HomeAppBar({
    required this.associationName,
    required this.onPressedLogout,
    required this.preferredSize,
    super.key
  });

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      leading: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: AppIcon(size: 32),
      ),
      title: Container(
        width: double.infinity,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(9999)
        ),
        alignment: Alignment.center,
        child: Text(
          associationName,
          style: const TextStyle(
            color: primaryColor,
            fontSize: bodyTextSize,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            icon: const LogoutIcon(
              size: 32,
              color: tertiaryColor
            ),
            onPressed: onPressedLogout
          )
        ),
      ]
    );
  }
}

// TODO: B-SAM っぽいデザインに変更する
Future<void> logoutDialogBuilder(BuildContext context, WidgetRef ref) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('本当にログアウトしますか？'),
          content: const Text('再度ログインするには、協会IDとパスワードの入力が必要です。'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('いいえ'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('はい'),
              onPressed: () async {
                await deleteToken(ref);
                if (context.mounted) {
                  context.go(loginPagePath);
                }
              },
            ),
          ],
        );
      },
    );
  }
