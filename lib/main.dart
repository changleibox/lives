// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/routes/routes.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const LivesApp());
}

/// 启动App
class LivesApp extends StatelessWidget {
  /// 构建一个启动App
  const LivesApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: '腾讯直播',
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xfff56494)
      ),
      routes: RouteProvider.routes,
      initialRoute: Navigator.defaultRouteName,
      builder: (context, child) {
        return OKToast(
          position: ToastPosition.bottom,
          child: child!,
        );
      },
    );
  }
}
