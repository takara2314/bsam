import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sailing_assist_mie/pages/home.dart';
import 'package:sailing_assist_mie/pages/next.dart';

final routerProvider = Provider((ref) => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => const MaterialPage(
        child: Home(title: 'Sailing Assist Mie')
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
