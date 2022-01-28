// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:lives/widgets/player_background.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_video_view.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播播放器
class LiveVideoPlayer extends StatefulWidget {
  /// 直播播放器
  const LiveVideoPlayer({
    Key? key,
    this.onViewCreated,
    this.gestureRecognizers,
  }) : super(key: key);

  /// [TRTCCloudVideoView.onViewCreated]
  final ValueChanged<int>? onViewCreated;

  /// [TRTCCloudVideoView.gestureRecognizers]
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  @override
  _LiveVideoPlayerState createState() => _LiveVideoPlayerState();
}

class _LiveVideoPlayerState extends State<LiveVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return PlayerBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return TRTCCloudVideoView(
            viewType: TRTCCloudDef.TRTC_VideoView_TextureView,
            viewMode: TRTCCloudDef.TRTC_VideoView_Model_Virtual,
            onViewCreated: widget.onViewCreated,
            gestureRecognizers: widget.gestureRecognizers,
          );
        },
      ),
    );
  }
}
