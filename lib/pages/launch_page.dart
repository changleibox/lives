// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:lives/generated/assets.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';

/// Created by changlei on 2022/1/18.
///
/// 闪屏页
class LaunchPage extends StatefulWidget with HostProvider {
  /// 构建闪屏页
  const LaunchPage({Key? key}) : super(key: key);

  @override
  _LaunchPageState createState() => _LaunchPageState();

  @override
  _LaunchPresenter createPresenter() => _LaunchPresenter();
}

class _LaunchPageState extends HostState<LaunchPage, _LaunchPresenter> {
  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return CupertinoPageScaffold(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Image.asset(
              Assets.images(Images.tencent_cloud),
              width: 240,
            ),
          ),
          Positioned(
            bottom: bottom + 16,
            child: const Text(
              'Copyright (c) 2022 GRASP. All rights reserved.\n由腾讯云提供技术支持',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 闪屏页
class _LaunchPresenter extends Presenter<LaunchPage> {
  Timer? _timer;

  @override
  Future<void> onStabled() async {
    super.onStabled();
    await Future.wait(<Future<void>>[
      Future<void>.delayed(const Duration(seconds: 3)),
      Lives.setup(),
    ]);
    if (Lives.isLogged) {
      unawaited(Routes.home.pushNamedAndRemoveUntil(context, (route) => false));
    } else {
      unawaited(Routes.login.pushNamedAndRemoveUntil(context, (route) => false));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
