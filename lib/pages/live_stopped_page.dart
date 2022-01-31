// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';

/// Created by box on 2022/1/31.
///
/// 直播已停止
class LiveStoppedPage extends StatelessWidget {
  /// 直播已停止
  const LiveStoppedPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('直播已结束'),
      ),
      child: Container(),
    );
  }
}
