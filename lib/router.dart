import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailing_assist_mie/pages/home.dart';
import 'package:sailing_assist_mie/pages/next.dart';
import 'package:sailing_assist_mie/pages/select_race.dart';
import 'package:sailing_assist_mie/pages/race/course.dart';
import 'package:sailing_assist_mie/pages/race/navi.dart';

final routerProvider = Provider((ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(
        child: Home()
      )
    ),
    GoRoute(
      path: '/select-race',
      pageBuilder: (context, state) => const MaterialPage(
        child: SelectRace()
      )
    ),
    GoRoute(
      path: '/race/course',
      pageBuilder: (context, state) => const MaterialPage(
        child: RaceCourse()
      )
    ),
    GoRoute(
      path: '/race/navi',
      pageBuilder: (context, state) => const MaterialPage(
        child: RaceNavi()
      )
    ),
    GoRoute(
      path: '/next',
      pageBuilder: (context, state) => const MaterialPage(
        child: Next()
      )
    )
  ]
));
