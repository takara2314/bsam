import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SelectRace extends HookConsumerWidget {
  const SelectRace({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(100, 100, 100, 1)
          ),
          onPressed: () => context.go('/')
        ),
        centerTitle: false,
        title: const Text(
          'コース選択',
          style: TextStyle(
            color: Color.fromRGBO(100, 100, 100, 1)
          )
        ),
        elevation: 0,
        backgroundColor: Colors.transparent
      ),
      body: Center(
        child: Column(
          children: [
            Row(
              children: [
                // TextField(
                //   decoration: const InputDecoration(
                //     hintText: 'ここに入力して検索'
                //   ),
                //   onChanged: (String e) {}
                // ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {}
                )
              ]
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 7.5),
                    child: const Text(
                      '今日',
                      style: TextStyle(fontSize: 28)
                    )
                  ),
                  SizedBox(
                    width: _width,
                    child: DecoratedBox(
                      child: StaggeredGrid.count(
                        crossAxisCount: 8,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 8,
                        children: [
                          const StaggeredGridTile.count(
                            crossAxisCellCount: 8,
                            mainAxisCellCount: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16)
                              ),
                              child: Image(
                                image: AssetImage('images/sailing.jpg'),
                                fit: BoxFit.cover
                              )
                            )
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 5,
                            mainAxisCellCount: 1,
                            child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              alignment: Alignment.bottomLeft,
                              child: const Text(
                                '伊勢湾レースA',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold
                                )
                              )
                            )
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 3,
                            mainAxisCellCount: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15, bottom: 25, right: 15),
                              child: ElevatedButton(
                                child: const Text(
                                  'レースする',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  )
                                ),
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  primary: const Color.fromRGBO(4, 111, 171, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)
                                  ),
                                )
                              )
                            )
                          ),
                          StaggeredGridTile.count(
                            crossAxisCellCount: 5,
                            mainAxisCellCount: 1,
                            child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              alignment: Alignment.topLeft,
                              child: const Text(
                                '10時15分〜11時30分',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(107, 107, 107, 1)
                                )
                              )
                            )
                          ),
                          const StaggeredGridTile.count(
                            crossAxisCellCount: 8,
                            mainAxisCellCount: 1,
                            child: Padding(
                              padding: EdgeInsets.only(left: 15),
                              child: Text(
                                '伊勢湾にて行います。初心者向け',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(107, 107, 107, 1)
                                )
                              )
                            )
                          )
                        ]
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(238, 238, 238, 1),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.25),
                            blurRadius: 7.5,
                            offset: Offset(0, 4)
                          )
                        ]
                      )
                    )
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              padding: const EdgeInsets.all(25)
            )
          ],
        )
      )
    );
  }
}
