// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/player_background.dart';
import 'package:provider/provider.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播播放器
class LiveCapturePlayer extends StatefulWidget {
  /// 直播播放器
  const LiveCapturePlayer({Key? key}) : super(key: key);

  @override
  _LiveCapturePlayerState createState() => _LiveCapturePlayerState();
}

class _LiveCapturePlayerState extends State<LiveCapturePlayer> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return PlayerBackground(
      child: Center(
        child: Text(
          model.started ? '录屏中，可切换到游戏界面直播啦' : '开始直播后，观众会实时看到你手机上\n的游戏画面，或其他应哟过',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
      ),
    );
  }
}
