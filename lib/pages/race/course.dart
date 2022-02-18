import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RaceCourse extends HookConsumerWidget {
  const RaceCourse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/select-race')
        ),
        centerTitle: false,
        title: const Text(
          '伊勢湾レースA',
          style: TextStyle(
            color: Color.fromRGBO(100, 100, 100, 1)
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent
      ),
      body: const GoogleMap(
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        initialCameraPosition: CameraPosition(
          target: LatLng(37.773972, -122.431297),
          zoom: 11.7
        )
      )
    );
  }
}
