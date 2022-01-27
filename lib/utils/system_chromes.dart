// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
}
