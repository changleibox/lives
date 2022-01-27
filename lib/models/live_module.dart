// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:lives/models/live_room_def.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';

/// Created by changlei on 2022/1/27.
///
/// 直播
abstract class LiveModule {
  /// 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
  /// @param userName 用户昵称
  /// @param avatarURL 用户头像
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL);

  //////////////////////////////////////////////////////////
  //
  //                 房间管理接口
  //
  //////////////////////////////////////////////////////////

  /// 获取房间列表的详细信息
  /// 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
  /// @param roomIdList 房间id列表
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIds);

  /// 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
  Future<UserListCallback> getAnchorInfo();

  /// 获取群成员列表。
  Future<UserListCallback> getRoomMemberInfo(int nextSeq);

  /// 更新本地视频预览画面的窗口,仅仅ios有效
  Future<void> updateLocalView();

  /// 更新远端视频画面的窗口,仅仅ios有效
  Future<void> updateRemoteView(String userId, int viewId);

  /// 观众请求连麦。
  Future<ActionCallback> requestJoinAnchor();

  /// 主播处理连麦请求。
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree, String callId);

  /// 主播踢除连麦观众。
  Future<ActionCallback> kickOutJoinAnchor(String userId);

  /// 主播请求跨房 PK。
  Future<ActionCallback> requestRoomPK(int roomId, String userId);

  /// 主播响应跨房 PK 请求。
  Future<ActionCallback> responseRoomPK(String userId, bool agree);

  /// 退出跨房 PK。
  Future<ActionCallback> quitRoomPK();

  /// 切换前后摄像头。
  /// @param isFrontCamera true:切换前置摄像头 false:切换后置摄像头
  Future<void> switchCamera();

  /// 开关闪光灯
  Future<void> enableCameraTorch();

  /// 设置是否镜像展示。
  Future<void> setMirror();

  /// 开启本地静音。
  /// @param mute 是否静音
  Future<void> muteLocalAudio();

  /// 静音远端音频。
  /// @param userId 远端用户id
  /// @param mute 是否静音
  Future<void> muteRemoteAudio(String userId, bool mute);

  /// 静音所有远端音频。
  /// @param mute 是否静音
  Future<void> muteAllRemoteAudio();

  /// 获取背景音乐音效管理对象 TXAudioEffectManager。
  TXAudioEffectManager get audioEffectManager;

  /// 获取美颜管理对象 TXBeautyManager。
  TXBeautyManager get beautyManager;

  /// 发送自定义文本消息。
  /// @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
  /// @param message 文本消息
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message);
}
