// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';

/// Created by changlei on 2022/1/27.
///
/// 直播类型
enum LiveType {
  /// 视频
  video,

  /// 游戏
  game,

  /// 语音
  voice,
}

/// 直播类型名称
extension LiveTypeName on LiveType {
  /// 名称
  String get label {
    switch (this) {
      case LiveType.video:
        return '视频';
      case LiveType.game:
        return '游戏';
      case LiveType.voice:
        return '语音';
    }
  }

  /// 对应的scene
  int get scene {
    return this == LiveType.voice ? TRTCCloudDef.TRTC_APP_SCENE_VOICE_CHATROOM : TRTCCloudDef.TRTC_APP_SCENE_LIVE;
  }
}
