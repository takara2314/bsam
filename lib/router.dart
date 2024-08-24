import 'package:go_router/go_router.dart';
import 'package:bsam/presentation/pages/auth.dart';
import 'package:bsam/presentation/pages/home.dart';
import 'package:bsam/presentation/pages/login.dart';
import 'package:bsam/presentation/pages/race.dart';

const authPagePath = '/auth';
const loginPagePath = '/login';
const homePagePath = '/';
const racePagePath = '/race';

final GoRouter router = GoRouter(
  initialLocation: authPagePath,
  routes: [
    GoRoute(
      path: authPagePath,
      builder: (context, state) => const AuthPage(),
    ),
    GoRoute(
      path: loginPagePath,
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: homePagePath,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: racePagePath,
      builder: (context, state) => const RacePage(),
    ),
  ],
);
