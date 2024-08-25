import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

const basicIconColor = Color.fromARGB(255, 62, 62, 62);

class AppIcon extends StatelessWidget {
  final double size;

  const AppIcon({
    required this.size,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icon.svg',
      semanticsLabel: 'App Icon',
      width: size,
      height: size,
    );
  }
}

class NoNetworkIcon extends StatelessWidget {
  final double size;

  const NoNetworkIcon({
    required this.size,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/no_network_icon.svg',
      semanticsLabel: 'No Network Icon',
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(
        basicIconColor,
        BlendMode.srcIn,
      ),
    );
  }
}

class ErrorIcon extends StatelessWidget {
  final double size;

  const ErrorIcon({
    required this.size,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/error_icon.svg',
      semanticsLabel: 'Error Icon',
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(
        basicIconColor,
        BlendMode.srcIn,
      ),
    );
  }
}

class LogoutIcon extends StatelessWidget {
  final double size;

  const LogoutIcon({
    required this.size,
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logout_icon.svg',
      semanticsLabel: 'Logout Icon',
      width: size,
      height: size,
      colorFilter: const ColorFilter.mode(
        basicIconColor,
        BlendMode.srcIn,
      ),
    );
  }
}
