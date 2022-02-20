import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sailing_assist_mie/providers/count.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Settings extends HookConsumerWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double _width = MediaQuery.of(context).size.width;
    double _height = MediaQuery.of(context).size.height;

    final _appBar = AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios,
          color: Color.fromRGBO(100, 100, 100, 1)
        ),
        onPressed: () => context.go('/')
      ),
      centerTitle: false,
      title: const Text(
        '設定',
        style: TextStyle(
          color: Colors.black
        )
      ),
      elevation: 0,
      backgroundColor: Colors.transparent
    );

    return Scaffold(
      appBar: _appBar,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              width: _width,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 10
                      ),
                      image: const DecorationImage(
                        fit: BoxFit.fill,
                        image: AssetImage('images/sample-icon.png')
                      )
                    )
                  ),
                  Positioned(
                    bottom: -10,
                    right: 10,
                    child: TextButton(
                      child: const Text(
                        '画像を変更',
                        style: TextStyle(
                          color: Color.fromRGBO(100, 100, 100, 1),
                          fontSize: 20
                        )
                      ),
                      onPressed: () {}
                    )
                  )
                ]
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: const Text(
                '競技者',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              )
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              width: _width,
              height: _height - _appBar.preferredSize.height - 360,
              child: SingleChildScrollView(
                child: Container(
                  margin: const EdgeInsets.only(left: 20, right: 20),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.0),
                      1: FlexColumnWidth(2.0)
                    },
                    children: [
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      ),
                      TableRow(
                        children: [
                          Container(
                            height: 52,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Text(
                              '名前',
                              style: TextStyle(
                                fontSize: 20
                              )
                            )
                          ),
                          Container(
                            height: 52,
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              '濱口　宝',
                              style: TextStyle(
                                fontSize: 24
                              )
                            )
                          )
                        ]
                      )
                    ]
                  )
                )
              )
            ),
            TextButton(
              child: const Text(
                'ログアウトする',
                style: TextStyle(
                  color: Color.fromRGBO(100, 100, 100, 1),
                  fontSize: 24
                )
              ),
              onPressed: () {}
            )
          ],
        ),
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        alignment: Alignment.center,
      ),
      backgroundColor: const Color.fromRGBO(229, 229, 229, 1)
    );
  }
}
