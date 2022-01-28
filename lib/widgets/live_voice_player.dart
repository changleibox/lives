// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/player_background.dart';
import 'package:provider/provider.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播播放器
class LiveVoicePlayer extends StatefulWidget {
  /// 直播播放器
  const LiveVoicePlayer({
    Key? key,
    this.alignment = Alignment.center,
  }) : super(key: key);

  /// 对齐方式
  final AlignmentGeometry alignment;

  @override
  _LiveVoicePlayerState createState() => _LiveVoicePlayerState();
}

class _LiveVoicePlayerState extends State<LiveVoicePlayer> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    final userInfo = model.getMemberInfo(model.userId);
    return PlayerBackground(
      child: AnimatedAlign(
        duration: const Duration(
          milliseconds: 250,
        ),
        alignment: widget.alignment,
        child: Container(
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                color: CupertinoColors.white.withOpacity(0.2),
                width: 20,
              ),
            ),
          ),
          child: ClipOval(
            clipBehavior: Clip.antiAlias,
            child: CachedNetworkImage(
              imageUrl: userInfo?.userAvatar ?? avatar,
              width: 104,
              height: 104,
            ),
          ),
        ),
      ),
    );
  }
}
