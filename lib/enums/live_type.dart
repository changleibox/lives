// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:lives/utils/system_chromes.dart';
import 'package:replay_kit_launcher/replay_kit_launcher.dart';
import 'package:system_alert_window/system_alert_window.dart';
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

  /// 对应的直播主题
  String get theme {
    switch (this) {
      case LiveType.video:
        return '视频聊天';
      case LiveType.game:
        return '和平精英';
      case LiveType.voice:
        return '聊天电台';
    }
  }

  /// 显示屏幕分享Window
  Future<void> startLive([FutureOr<void> Function()? onStarted]) async {
    if (this != LiveType.game) {
      return;
    }
    if (Platform.isIOS) {
      await ReplayKitLauncher.launchReplayKitBroadcast('Upload');
    } else if (Platform.isAndroid) {
      if ((await SystemAlertWindow.requestPermissions()) == true) {
        await SystemAlertWindow.showSystemWindow(
          width: 18,
          height: 95,
          margin: SystemWindowMargin(top: 200),
          gravity: SystemWindowGravity.TOP,
          header: SystemWindowHeader(
            title: SystemWindowText(
              text: '屏幕分享中',
              fontSize: 14,
              textColor: CupertinoColors.label,
            ),
            decoration: SystemWindowDecoration(
              startColor: CupertinoColors.systemGrey,
            ),
          ),
        );
      }
    }
    await onStarted?.call();
    await SystemChromes.setPreferredOrientations(this);
  }

  /// 关闭
  Future<void> stopLive([FutureOr<void> Function()? onStopped]) async {
    if (this != LiveType.game) {
      return;
    }
    if (Platform.isIOS) {
      await ReplayKitLauncher.finishReplayKitBroadcast('ZGFinishBroadcastUploadExtensionProcessNotification');
    } else if (Platform.isAndroid) {
      await SystemAlertWindow.closeSystemWindow();
    }
    await onStopped?.call();
    await SystemChromes.setPreferredOrientations();
  }
}
