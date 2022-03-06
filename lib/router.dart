import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailing_assist_mie/pages/home.dart';
import 'package:sailing_assist_mie/pages/next.dart';
import 'package:sailing_assist_mie/pages/races.dart';
import 'package:sailing_assist_mie/pages/race/course.dart';
import 'package:sailing_assist_mie/pages/race/navi.dart';
import 'package:sailing_assist_mie/pages/settings.dart';

final routerProvider = Provider((ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(
        child: Home()
      )
    ),
    GoRoute(
      path: '/races',
      pageBuilder: (context, state) => const MaterialPage(
        child: Races()
      )
    ),
    GoRoute(
      path: '/race/course/:raceId',
      pageBuilder: (context, state) => MaterialPage(
        child: RaceCourse(raceId: state.params['raceId'] ?? '')
      )
    ),
    GoRoute(
      path: '/race/navi/:raceId',
      pageBuilder: (context, state) => MaterialPage(
        child: RaceNavi(raceId: state.params['raceId'] ?? '')
      )
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => const MaterialPage(
        child: Settings()
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
