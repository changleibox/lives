// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/pages/home_page.dart';
import 'package:lives/pages/launch_page.dart';
import 'package:lives/pages/live_page.dart';
import 'package:lives/pages/login_page.dart';
import 'package:lives/pages/watch_page.dart';

/// Created by changlei on 2022/1/18.
///
/// 路由名称
enum Routes {
  /// 登录
  login,

  /// 首页
  home,

  /// 直播页面
  live,

  /// 观看页面
  watch,
}

/// 路由
class RouteProvider {
  const RouteProvider._();

  static final _routes = <String, WidgetBuilder>{
    Navigator.defaultRouteName: (context) => const LaunchPage(),
    Routes.login.name: (context) => const LoginPage(),
    Routes.home.name: (context) => const HomePage(),
    Routes.live.name: (context) => const LivePage(),
    Routes.watch.name: (context) => const WatchPage(),
  };

  /// 路由表
  static Map<String, WidgetBuilder> get routes => Map.unmodifiable(_routes);
}

/// 扩展routeName路由属性
extension RouteNameExtension on Routes {
  /// [Navigator.pushNamed]
  Future<T?> pushNamed<T extends Object?>(
    BuildContext context, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      name,
      arguments: arguments,
    );
  }

  /// [Navigator.pushNamedAndRemoveUntil]
  Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      name,
      predicate,
      arguments: arguments,
    );
  }

  /// [Navigator.pushReplacementNamed]
  Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      name,
      result: result,
      arguments: arguments,
    );
  }

  /// [Navigator.popAndPushNamed]
  Future<T?> popAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.popAndPushNamed<T, TO>(
      context,
      name,
      result: result,
      arguments: arguments,
    );
  }

  /// [Navigator.restorablePopAndPushNamed]
  String restorablePopAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.restorablePopAndPushNamed<T, TO>(
      context,
      name,
      result: result,
      arguments: arguments,
    );
  }
}
