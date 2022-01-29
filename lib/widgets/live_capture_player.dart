// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/widgets/player_background.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播播放器
class LiveCapturePlayer extends StatefulWidget {
  /// 直播播放器
  const LiveCapturePlayer({
    Key? key,
    this.started = false,
  }) : super(key: key);

  /// 是否开始
  final bool started;

  @override
  _LiveCapturePlayerState createState() => _LiveCapturePlayerState();
}

class _LiveCapturePlayerState extends State<LiveCapturePlayer> {
  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final padding = mediaQueryData.padding;
    final orientation = mediaQueryData.orientation;
    Widget child = Text(
      widget.started ? '录屏中，可切换到游戏界面直播啦' : '开始直播后，观众会实时看到你手机上\n的游戏画面，或其他应哟过',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: CupertinoColors.white,
      ),
    );
    var alignment = Alignment.center;
    if (widget.started && orientation == Orientation.landscape) {
      alignment = const Alignment(0.0, -0.4);
      child = Container(
        decoration: BoxDecoration(
          color: CupertinoColors.systemGrey5.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(10),
        margin: EdgeInsets.only(
          left: padding.left + 16,
          right: 16,
        ),
        width: double.infinity,
        child: child,
      );
    }
    return PlayerBackground(
      child: AnimatedAlign(
        duration: const Duration(
          milliseconds: 250,
        ),
        alignment: alignment,
        child: child,
      ),
    );
  }
}
