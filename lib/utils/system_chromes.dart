// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lives/enums/live_type.dart';

const _overlayStyle = SystemUiOverlayStyle(
  statusBarColor: Color(0x00ffffff),
  systemNavigationBarColor: Color(0x00ffffff),
  systemNavigationBarDividerColor: Color(0x00ffffff),
  systemStatusBarContrastEnforced: true,
  systemNavigationBarContrastEnforced: true,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

/// Created by changlei on 2022/1/27.
///
/// 样式
class SystemChromes {
  const SystemChromes._();

  /// 配置
  static SystemUiOverlayStyle get overlayStyle => _overlayStyle;

  /// 直播
  static SystemUiOverlayStyle get liveOverlayStyle {
    return _overlayStyle.copyWith(
      systemNavigationBarColor: CupertinoColors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    );
  }

  /// 设置屏幕方向
  static Future<void> setSystemPreferredOrientations() async {
    await SystemChrome.setPreferredOrientations(DeviceOrientation.values);
  }

  /// 设置屏幕方向
  static Future<void> setLivePreferredOrientations() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  /// 直播方向
  static Future<void> setPreferredOrientations([LiveType? liveType]) async {
    switch (liveType) {
      case LiveType.video:
      case LiveType.voice:
      case null:
        await SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.portraitUp,
        ]);
        break;
      case LiveType.game:
        await SystemChrome.setPreferredOrientations(const [
          DeviceOrientation.landscapeRight,
        ]);
        break;
    }
  }
}
