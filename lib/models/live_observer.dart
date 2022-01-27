// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:lives/entries/bullet_chat.dart';
import 'package:lives/models/live_room_def.dart';
import 'package:lives/models/live_room_delegate.dart';

/// Created by changlei on 2022/1/24.
///
/// 直播事件监听
abstract class LiveObserver {
  /// [TRTCLiveRoomDelegate.onError]
  void onError(Object? params) {}

  /// [TRTCLiveRoomDelegate.onWarning]
  void onWarning(Object? params) {}

  /// [TRTCLiveRoomDelegate.onEnterRoom]
  void onEnterRoom(Object? params) {}

  /// [TRTCLiveRoomDelegate.onUserVideoAvailable]
  void onUserVideoAvailable(Object? params) {}

  /// [TRTCLiveRoomDelegate.onAnchorEnter]
  void onAnchorEnter(Object? params) {}

  /// [TRTCLiveRoomDelegate.onAnchorExit]
  void onAnchorExit(Object? params) {}

  /// [TRTCLiveRoomDelegate.onRequestJoinAnchor]
  void onRequestJoinAnchor(Object? params) {}

  /// [TRTCLiveRoomDelegate.onKickOutJoinAnchor]
  void onKickOutJoinAnchor(Object? params) {}

  /// [TRTCLiveRoomDelegate.onAnchorAccepted]
  void onAnchorAccepted(Object? params) {}

  /// [TRTCLiveRoomDelegate.onAnchorRejected]
  void onAnchorRejected(Object? params) {}

  /// [TRTCLiveRoomDelegate.onInvitationTimeout]
  void onInvitationTimeout(Object? params) {}

  /// [TRTCLiveRoomDelegate.onRequestRoomPK]
  void onRequestRoomPK(Object? params) {}

  /// [TRTCLiveRoomDelegate.onRoomPKAccepted]
  void onRoomPKAccepted(Object? params) {}

  /// [TRTCLiveRoomDelegate.onRoomPKRejected]
  void onRoomPKRejected(Object? params) {}

  /// [TRTCLiveRoomDelegate.onQuitRoomPK]
  void onQuitRoomPK(Object? params) {}

  /// [TRTCLiveRoomDelegate.onRoomDestroy]
  void onRoomDestroy(Object? params) {}

  /// [TRTCLiveRoomDelegate.onAudienceEnter]
  void onAudienceEnter(UserInfo userInfo) {}

  /// [TRTCLiveRoomDelegate.onAudienceExit]
  void onAudienceExit(UserInfo userInfo) {}

  /// [TRTCLiveRoomDelegate.onUserVolumeUpdate]
  void onUserVolumeUpdate(Object? params) {}

  /// [TRTCLiveRoomDelegate.onReceiveRoomTextMsg]
  void onReceiveRoomTextMsg(BulletChat bulletChat) {}

  /// [TRTCLiveRoomDelegate.onReceiveRoomCustomMsg]
  void onReceiveRoomCustomMsg(Object? params) {}

  /// [TRTCLiveRoomDelegate.onKickedOffline]
  void onKickedOffline(Object? params) {}
}

/// 扩展[LiveObserver]
extension LiverObservers on Iterable<LiveObserver> {
  /// 事件
  void notify(TRTCLiveRoomDelegate type, dynamic params) {
    for (var listener in this) {
      switch (type) {
        case TRTCLiveRoomDelegate.onError:
          listener.onError(params);
          break;
        case TRTCLiveRoomDelegate.onWarning:
          listener.onWarning(params);
          break;
        case TRTCLiveRoomDelegate.onEnterRoom:
          listener.onEnterRoom(params);
          break;
        case TRTCLiveRoomDelegate.onUserVideoAvailable:
          listener.onUserVideoAvailable(params);
          break;
        case TRTCLiveRoomDelegate.onAnchorEnter:
          listener.onAnchorEnter(params);
          break;
        case TRTCLiveRoomDelegate.onAnchorExit:
          listener.onAnchorExit(params);
          break;
        case TRTCLiveRoomDelegate.onRequestJoinAnchor:
          listener.onRequestJoinAnchor(params);
          break;
        case TRTCLiveRoomDelegate.onKickOutJoinAnchor:
          listener.onKickOutJoinAnchor(params);
          break;
        case TRTCLiveRoomDelegate.onAnchorAccepted:
          listener.onAnchorAccepted(params);
          break;
        case TRTCLiveRoomDelegate.onAnchorRejected:
          listener.onAnchorRejected(params);
          break;
        case TRTCLiveRoomDelegate.onInvitationTimeout:
          listener.onInvitationTimeout(params);
          break;
        case TRTCLiveRoomDelegate.onRequestRoomPK:
          listener.onRequestRoomPK(params);
          break;
        case TRTCLiveRoomDelegate.onRoomPKAccepted:
          listener.onRoomPKAccepted(params);
          break;
        case TRTCLiveRoomDelegate.onRoomPKRejected:
          listener.onRoomPKRejected(params);
          break;
        case TRTCLiveRoomDelegate.onQuitRoomPK:
          listener.onQuitRoomPK(params);
          break;
        case TRTCLiveRoomDelegate.onRoomDestroy:
          listener.onRoomDestroy(params);
          break;
        case TRTCLiveRoomDelegate.onAudienceEnter:
          listener.onAudienceEnter(UserInfo.fromJson(params as Map<String, dynamic>));
          break;
        case TRTCLiveRoomDelegate.onAudienceExit:
          listener.onAudienceExit(UserInfo.fromJson(params as Map<String, dynamic>));
          break;
        case TRTCLiveRoomDelegate.onUserVolumeUpdate:
          listener.onUserVolumeUpdate(params);
          break;
        case TRTCLiveRoomDelegate.onReceiveRoomTextMsg:
          listener.onReceiveRoomTextMsg(BulletChat.fromJson(params as Map<String, dynamic>));
          break;
        case TRTCLiveRoomDelegate.onReceiveRoomCustomMsg:
          listener.onReceiveRoomCustomMsg(params);
          break;
        case TRTCLiveRoomDelegate.onKickedOffline:
          listener.onKickedOffline(params);
          break;
      }
    }
  }
}
