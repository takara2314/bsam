import 'dart:async';

import 'package:bsam/app/game/detail/hook.dart';
import 'package:bsam/app/jwt/jwt.dart';
import 'package:bsam/domain/athlete.dart';
import 'package:bsam/infrastructure/repository/token.dart';
import 'package:bsam/infrastructure/repository/ttsSpeed.dart';
import 'package:bsam/main.dart';
import 'package:bsam/presentation/widgets/button.dart';
import 'package:bsam/presentation/widgets/icon.dart';
import 'package:bsam/presentation/widgets/text.dart';
import 'package:bsam/provider.dart';
import 'package:bsam/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenNotifier = ref.watch(tokenProvider.notifier);
    final chosenAthleteId = useState<String?>(null);
    final jwt = Jwt.fromToken(tokenNotifier.state);
    final isActive = useState(true);

    final raceDetail = useRaceDetailAlwaysFetch(
      context,
      jwt.associationId,
      tokenNotifier.state,
      isActive,
    );

    void setChosenAthleteId(String? athleteId) {
      chosenAthleteId.value = athleteId;
    }

    return Scaffold(
      appBar: HomeAppBar(
        associationName: Jwt.fromToken(tokenNotifier.state).associationName,
        onPressedLogout: () => logoutDialogBuilder(context, ref),
        preferredSize: const Size.fromHeight(72),
      ),
      body: Center(
        child: Column(
          children: [
            Heading(raceDetail.value?.name ?? '読み込み中...'),
            ChoiceAthlete(
              chosenAthleteId: chosenAthleteId.value,
              setChosenAthleteId: setChosenAthleteId,
              joinedAthleteIds: raceDetail.value?.athleteIds ?? [],
            ),
            RaceStartButton(
              chosenAthleteId: chosenAthleteId.value,
              joinedAthleteIds: raceDetail.value?.athleteIds ?? [],
              onPressed: () {
                // ボタンが押されたとき、レースページに移動する
                isActive.value = false;
                context.push('$racePagePathBase${chosenAthleteId.value}').then((_) {
                  isActive.value = true;
                });
              }
            ),
            TTSSpeedRange()
          ]
        )
      )
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

class ChoiceAthlete extends StatelessWidget {
  final String? chosenAthleteId;
  final void Function(String?) setChosenAthleteId;
  final List<String> joinedAthleteIds;

  const ChoiceAthlete({
    required this.chosenAthleteId,
    required this.setChosenAthleteId,
    required this.joinedAthleteIds,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> athleteNumbers = List.generate(
      maxAthleteNo, (index) => index + 1
    );
    final List<List<int>> chunkedAthleteNumbers = [];

    // 1列に5つの選手を表示する
    for (int i = 0; i < athleteNumbers.length; i += 5) {
      chunkedAthleteNumbers.add(athleteNumbers.sublist(i, i + 5));
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        top: 10,
        left: 30,
        right: 30,
      ),
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 10,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: chunkedAthleteNumbers.map((athleteNumbersRow) {
          return Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: athleteNumbersRow.map((athleteNumber) {
                return ChoiceAthleteChip(
                  athleteName: '$athleteNumber番艇', // 直接数字を使う
                  athleteId: 'athlete$athleteNumber', // 直接数字を使う
                  chosenAthleteId: chosenAthleteId,
                  setChosenAthleteId: setChosenAthleteId,
                  joinedAthleteIds: joinedAthleteIds
                );
              }).toList(),
            )
          );
        }).toList(),
      ),
    );
  }
}

class ChoiceAthleteChip extends StatelessWidget {
  final String athleteName;
  final String athleteId;
  final String? chosenAthleteId;
  final void Function(String?) setChosenAthleteId;
  final List<String> joinedAthleteIds;

  const ChoiceAthleteChip({
    required this.athleteName,
    required this.athleteId,
    required this.chosenAthleteId,
    required this.setChosenAthleteId,
    required this.joinedAthleteIds,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    bool selected = athleteId == chosenAthleteId;
    bool alreadyJoined = joinedAthleteIds.contains(athleteId);

    return Container(
      width: 128,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? secondaryColor : Colors.transparent,
          width: 3,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: ChoiceChip(
        label: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Text(
            athleteName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: bodyTextSize,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        selected: selected,
        onSelected: alreadyJoined ? null : (bool selected) {
          setChosenAthleteId(athleteId);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        selectedColor: backgroundColor,
        backgroundColor: backgroundColor,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        showCheckmark: false,
        side: BorderSide.none,
      ),
    );
  }
}

class RaceStartButton extends StatelessWidget {
  final String? chosenAthleteId;
  final List<String> joinedAthleteIds;
  final void Function() onPressed;

  const RaceStartButton({
    required this.chosenAthleteId,
    required this.joinedAthleteIds,
    required this.onPressed,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    String label;
    if (chosenAthleteId == null) {
      label = '選手を選択してください';
    } else if (joinedAthleteIds.contains(chosenAthleteId)) {
      label = 'この艇はすでに参加しています';
    } else {
      label = 'レースを開始する';
    }

    bool disabled = (
      chosenAthleteId == null
      || joinedAthleteIds.contains(chosenAthleteId)
    ) ? true : false;

    return Container(
      margin: const EdgeInsets.only(
        top: 20,
        left: 30,
        right: 30,
      ),
      child: PrimaryButton(
        label: label,
        onPressed: disabled ? null : onPressed
      )
    );
  }
}

class TTSSpeedRange extends HookConsumerWidget {
  const TTSSpeedRange({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsSpeedNotifier = ref.watch(ttsSpeedProvider.notifier);
    final localSpeed = useState(ref.read(ttsSpeedProvider));

    useEffect(() {
      loadTtsSpeed(ref);
      localSpeed.value = ttsSpeedNotifier.state;
      return null;
    }, [ttsSpeedNotifier.state]);

    return Container(
      margin: const EdgeInsets.only(
        top: 50,
      ),
      padding: const EdgeInsets.only(
        left: 30,
        right: 30,
      ),
      child: Column(
        children: [
          const Heading('アナウンス速度'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              const NormalText('遅い'),
              Slider(
                value: localSpeed.value,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                activeColor: primaryColor,
                thumbColor: primaryColor,
                // スライダー操作中はローカルstateのみ更新
                onChanged: (double value) {
                  localSpeed.value = value;
                },
                // スライダー操作完了時にProviderを更新して永続化
                onChangeEnd: (double value) {
                  ttsSpeedNotifier.state = value;
                  saveTtsSpeed(ref, value);
                },
              ),
              const NormalText('速い'),
            ]
          ),
        ],
      ),
    );
  }
}
