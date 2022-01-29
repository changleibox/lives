// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/utils/system_chromes.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(const LivesApp());
  SystemChromes.setPreferredOrientations();
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
        primaryColor: Color(0xfff56494),
      ),
      routes: RouteProvider.routes,
      initialRoute: Navigator.defaultRouteName,
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemChromes.overlayStyle,
          child: OKToast(
            position: ToastPosition.center,
            backgroundColor: CupertinoColors.black.withOpacity(0.8),
            radius: 8,
            textPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
