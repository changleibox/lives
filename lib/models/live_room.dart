// Copyright (c) 2022 CHANGLEI. All rights reserved.

// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:lives/models/live_im.dart';
import 'package:lives/models/live_room_def.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_group_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_signaling_manager.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

const int _codeErr = -1;

/// 自己封装的聊天室工具类
abstract class TRTCLiveRoom {
  /// 获取 TRTCLiveRoom 单例对象
  /// @return TRTCLiveRoom 实例
  /// @note 可以调用 {@link TRTCLiveRoom.destroySharedInstance()} 销毁单例对象
  static Future<TRTCLiveRoom> sharedInstance() async {
    return _TRTCLiveRoom.sharedInstance();
  }

  /// 销毁 TRTCLiveRoom 单例对象
  /// @note 销毁实例后，外部缓存的 TRTCLiveRoom 实例不能再使用，需要重新调用 {@link TRTCLiveRoom.sharedInstance()} 获取新实例
  static Future<void> destroySharedInstance() async {
    await _TRTCLiveRoom.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  //
  //                 基础接口
  //
  //////////////////////////////////////////////////////////

  /// 设置组件事件监听接口
  /// 您可以通过 registerListener 获得 TRTCCalling 的各种状态通知
  /// @param VoiceListenerFunc func 回调接口
  void addListener(VoiceListener listener);

  /// 移除组件事件监听接口
  void removeListener(VoiceListener listener);

  /// 设置组件事件监听接口
  /// 您可以通过 registerListener 获得 TRTCCalling 的各种状态通知
  /// @param VoiceListenerFunc func 回调接口
  void addTRTCListener(ListenerValue listener);

  /// 移除组件事件监听接口
  void removeTRTCListener(ListenerValue listener);

  /// 登录
  /// @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
  /// @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
  /// @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
  /// @param 返回值：成功时 code 为0
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig, TRTCLiveRoomConfig config);

  /// 退出登录
  Future<ActionCallback> logout();

  /// 设置用户信息，您设置的用户信息会被存储于腾讯云 IM 云服务中。
  /// @param userName 用户昵称
  /// @param avatarURL 用户头像
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL);

  //////////////////////////////////////////////////////////
  //
  //                 房间管理接口
  //
  //////////////////////////////////////////////////////////

  /// 创建房间（房间创建者调用）
  /// @param roomId 房间标识，需要由您分配并进行统一管理。
  /// @param roomParam 房间信息，用于房间描述的信息，例如房间名称，封面信息等。如果房间列表和房间信息都由您的服务器自行管理，可忽略该参数。
  /// @param callback 创建房间的结果回调，成功时 code 为0.
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam, {int? scene});

  /// 销毁房间（房间创建者调用）
  /// 主播在创建房间后，可以调用这个函数来销毁房间。
  Future<ActionCallback> destroyRoom();

  /// 进入房间（观众调用）
  /// @param roomId 房间标识
  Future<ActionCallback> enterRoom(int roomId, {int? scene});

  /// 退出房间（观众调用）
  Future<ActionCallback> exitRoom();

  /// 获取房间列表的详细信息
  /// 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
  /// @param roomIdList 房间id列表
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIds);

  /// 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
  Future<UserListCallback> getAnchorInfo();

  /// 获取群成员列表。
  Future<UserListCallback> getRoomMemberInfo(int nextSeq);

  /// 开启本地视频的预览画面。
  Future<void> startCameraPreview(bool isFrontCamera, int viewId);

  /// 更新本地视频预览画面的窗口,仅仅ios有效
  Future<void> updateLocalView(int viewId);

  /// 停止本地视频采集及预览。
  Future<void> stopCameraPreview();

  /// 开始直播（推流），适用于以下场景：
  /// 主播开播的时候调用
  /// 观众开始连麦时调用
  Future<void> startPublish(String? streamId);

  /// 停止直播（推流）。
  Future<void> stopPublish();

  /// 开始直播（推流），适用于以下场景：
  /// 主播开播的时候调用
  /// 观众开始连麦时调用
  Future<ActionCallback> startCapture({
    int? streamType,
    TRTCVideoEncParam? encParams,
    String appGroup = '',
  });

  /// 停止直播（推流）。
  Future<void> stopCapture();

  /// 开始直播（推流），适用于以下场景：
  /// 主播开播的时候调用
  /// 观众开始连麦时调用
  Future<ActionCallback> startVoice();

  /// 停止直播（推流）。
  Future<void> stopVoice();

  /// 播放远端视频画面，可以在普通观看和连麦场景中调用。
  Future<void> startPlay(String userId, int viewId);

  /// 更新远端视频画面的窗口,仅仅ios有效
  Future<void> updateRemoteView(String userId, int viewId);

  /// 停止渲染远端视频画面。
  Future<void> stopPlay(String userId);

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
  Future<void> switchCamera(bool isFrontCamera);

  /// 开关闪光灯
  Future<void> enableCameraTorch(bool enable);

  /// 设置是否镜像展示。
  Future<void> setMirror(bool isMirror);

  /// 开启本地静音。
  /// @param mute 是否静音
  Future<void> muteLocalAudio(bool mute);

  /// 静音远端音频。
  /// @param userId 远端用户id
  /// @param mute 是否静音
  Future<void> muteRemoteAudio(String userId, bool mute);

  /// 静音所有远端音频。
  /// @param mute 是否静音
  Future<void> muteAllRemoteAudio(bool mute);

  /// 获取背景音乐音效管理对象 TXAudioEffectManager。
  TXAudioEffectManager getAudioEffectManager();

  /// 获取美颜管理对象 TXBeautyManager。
  TXBeautyManager getBeautyManager();

  /// 在房间中广播文本消息，一般用于弹幕聊天
  /// @param message 文本消息
  Future<ActionCallback> sendRoomTextMsg(String message);

  /// 发送自定义文本消息。
  /// @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
  /// @param message 文本消息
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message);
}

class _TRTCLiveRoom extends TRTCLiveRoom {
  static _TRTCLiveRoom? _instance;

  late final TRTCCloud _cloud;
  late final TXAudioEffectManager _txAudioManager;
  late final TXDeviceManager _txDeviceManager;
  late final LiveIM _imManager;

  final Set<ListenerValue> _rtcListeners = {};

  late int _sdkAppId;
  late String _userSig;

  late int _originRole;

  String? _roomIdPK;
  String? _streamId;
  bool _isStartCapture = false;
  bool _isStartAudio = false;

  // ignore: unused_field
  TRTCLiveRoomConfig? _roomConfig;

  Future<void> _initTRTC() async {
    _cloud = (await TRTCCloud.sharedInstance())!;
    _txDeviceManager = _cloud.getDeviceManager();
    _txAudioManager = _cloud.getAudioEffectManager();
    _imManager = await LiveIM.sharedInstance();
  }

  static Future<_TRTCLiveRoom> sharedInstance() async {
    if (_instance == null) {
      _instance = _TRTCLiveRoom();
      await _instance!._initTRTC();
    }
    return _instance!;
  }

  static Future<void> destroySharedInstance() async {
    if (_instance != null) {
      _instance = null;
    }
    await TRTCCloud.destroySharedInstance();
    await LiveIM.destroySharedInstance();
  }

  V2TIMGroupManager get groupManager => _imManager.groupManager;

  V2TIMSignalingManager get signalingManager => _imManager.signalingManager;

  TXAudioEffectManager get audioEffectManager => _txAudioManager;

  @override
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam, {int? scene}) async {
    return await _imManager.createRoom(
      roomId: roomId,
      roomParam: roomParam,
      callback: () async {
        _originRole = TRTCCloudDef.TRTCRoleAnchor;
        await _cloud.enterRoom(
          TRTCParams(
            sdkAppId: _sdkAppId,
            //应用Id
            userId: _imManager.userId,
            // 用户Id
            userSig: _userSig,
            // 用户签名
            role: TRTCCloudDef.TRTCRoleAnchor,
            roomId: roomId,
          ),
          scene ?? TRTCCloudDef.TRTC_APP_SCENE_LIVE,
        );
        // 默认打开麦克风
        // await enableAudioVolumeEvaluation(true);
        if (roomParam.quality != null) {
          await _cloud.startLocalAudio(roomParam.quality!);
        } else {
          await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);
        }
      },
      scene: scene,
    );
  }

  @override
  Future<ActionCallback> destroyRoom() {
    return _imManager.destroyRoom(_cloud.exitRoom);
  }

  @override
  Future<ActionCallback> enterRoom(int roomId, {int? scene}) {
    return _imManager.enterRoom(
      roomId: roomId,
      scene: scene,
      callback: () async {
        _originRole = TRTCCloudDef.TRTCRoleAudience;
        await _cloud.enterRoom(
          TRTCParams(
            sdkAppId: _sdkAppId,
            //应用Id
            userId: _imManager.userId,
            // 用户Id
            userSig: _userSig,
            // 用户签名
            role: TRTCCloudDef.TRTCRoleAudience,
            roomId: roomId,
          ),
          scene ?? TRTCCloudDef.TRTC_APP_SCENE_LIVE,
        );
      },
    );
  }

  @override
  Future<ActionCallback> exitRoom() {
    return _imManager.exitRoom(_cloud.exitRoom);
  }

  @override
  Future<UserListCallback> getAnchorInfo() {
    return _imManager.getAnchorInfo();
  }

  @override
  Future<UserListCallback> getRoomMemberInfo(int nextSeq) {
    return _imManager.getRoomMemberInfo(nextSeq);
  }

  @override
  TXAudioEffectManager getAudioEffectManager() {
    return _cloud.getAudioEffectManager();
  }

  @override
  TXBeautyManager getBeautyManager() {
    return _cloud.getBeautyManager();
  }

  @override
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIdList) {
    return _imManager.getRoomInfo(roomIdList);
  }

  @override
  Future<ActionCallback> kickOutJoinAnchor(String userId) {
    return _imManager.kickOutJoinAnchor(userId);
  }

  @override
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig, TRTCLiveRoomConfig config) {
    _sdkAppId = sdkAppId;
    _userSig = userSig;
    _roomConfig = config;

    return _imManager.login(sdkAppId, userId, userSig);
  }

  @override
  Future<ActionCallback> logout() {
    _sdkAppId = 0;
    _userSig = '';
    return _imManager.logout();
  }

  @override
  Future<void> muteAllRemoteAudio(bool mute) {
    return _cloud.muteAllRemoteAudio(mute);
  }

  @override
  Future<void> muteLocalAudio(bool mute) {
    return _cloud.muteLocalAudio(mute);
  }

  @override
  Future<void> muteRemoteAudio(String userId, bool mute) {
    return _cloud.muteRemoteAudio(userId, mute);
  }

  @override
  Future<ActionCallback> quitRoomPK() {
    return _imManager.quitRoomPK(_cloud.disconnectOtherRoom);
  }

  @override
  void addListener(VoiceListener listener) {
    _imManager.addListener(listener, (value) {
      if (_rtcListeners.isEmpty && value) {
        // 监听rtc事件
        _cloud.registerListener(_rtcListener);
      }
    });
  }

  @override
  void removeListener(VoiceListener listener) {
    _imManager.removeListener(listener, (value) {
      if (_rtcListeners.isEmpty && value) {
        _cloud.unRegisterListener(_rtcListener);
      }
    });
  }

  @override
  void addTRTCListener(ListenerValue listener) {
    if (_rtcListeners.isEmpty && !_imManager.hasListeners) {
      // 监听rtc事件
      _cloud.registerListener(_rtcListener);
    }
    _rtcListeners.add(listener);
  }

  @override
  void removeTRTCListener(ListenerValue listener) {
    _rtcListeners.remove(_rtcListeners);
    if (_rtcListeners.isEmpty && !_imManager.hasListeners) {
      _cloud.unRegisterListener(_rtcListener);
    }
  }

  // rtc相关事件
  void _rtcListener(TRTCCloudListener rtcType, Object? param) {
    _imManager.rtcListener(rtcType, param);
    for (var rtcListener in _rtcListeners) {
      rtcListener(rtcType, param);
    }
  }

  @override
  Future<ActionCallback> requestJoinAnchor() {
    return _imManager.requestJoinAnchor();
  }

  @override
  Future<ActionCallback> requestRoomPK(int roomId, String userId) {
    return _imManager.requestRoomPK(roomId, userId);
  }

  @override
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree, String callId) {
    return _imManager.responseJoinAnchor(userId, agree, callId);
  }

  @override
  Future<ActionCallback> responseRoomPK(String userId, bool agree) {
    return _imManager.responseRoomPK(userId, agree, () async {
      await _cloud.connectOtherRoom(jsonEncode({
        'roomId': int.parse(_roomIdPK!),
        'userId': userId,
      }));
    });
  }

  @override
  Future<ActionCallback> sendRoomTextMsg(String message) {
    return _imManager.sendRoomTextMsg(message);
  }

  @override
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) {
    return _imManager.sendRoomCustomMsg(cmd, message);
  }

  @override
  Future<void> setMirror(bool isMirror) {
    if (isMirror) {
      return _cloud.setLocalRenderParams(const TRTCRenderParams(
        mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE,
      ));
    } else {
      return _cloud.setLocalRenderParams(const TRTCRenderParams(
        mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE,
      ));
    }
  }

  @override
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL) {
    return _imManager.setSelfProfile(userName, avatarURL);
  }

  @override
  Future<void> startCameraPreview(bool isFrontCamera, int viewId) {
    return _cloud.startLocalPreview(isFrontCamera, viewId);
  }

  @override
  Future<void> updateLocalView(int viewId) {
    return _cloud.updateLocalView(viewId);
  }

  @override
  Future<void> startPlay(String userId, int viewId) {
    return _cloud.startRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, viewId);
  }

  @override
  Future<void> updateRemoteView(String userId, int viewId) {
    return _cloud.updateRemoteView(viewId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG, userId);
  }

  @override
  Future<ActionCallback> startPublish(String? streamId) async {
    if (!_imManager.isEnterRoom) {
      return const ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    await _handleVideoEncoderParams();
    if (!_isEmpty(streamId)) {
      _streamId = streamId;
      await _cloud.startPublishing(streamId!, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);

    return const ActionCallback(code: 0, desc: 'startPublish success');
  }

  Future<void> _handleVideoEncoderParams() async {
    // 如果是观众，那么则切换到主播
    if (_originRole == TRTCCloudDef.TRTCRoleAudience) {
      await _cloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
      // 观众切换到主播是小主播，小主播设置一下分辨率
      const param = TRTCVideoEncParam(
        videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270,
        videoBitrate: 400,
        videoFps: 15,
        videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
      );
      await _cloud.setVideoEncoderParam(param);
    } else if (_originRole == TRTCCloudDef.TRTCRoleAnchor) {
      // 大主播的时候切换分辨率
      const param = TRTCVideoEncParam(
        videoResolution: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720,
        videoBitrate: 1800,
        videoFps: 15,
        enableAdjustRes: true,
        videoResolutionMode: TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT,
      );
      await _cloud.setVideoEncoderParam(param);
    }
  }

  bool _isEmpty(String? data) {
    return data == null || data == '';
  }

  @override
  Future<void> stopCameraPreview() {
    return _cloud.stopLocalPreview();
  }

  @override
  Future<void> stopPlay(String userId) {
    return _cloud.stopRemoteView(userId, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
  }

  @override
  Future<void> stopPublish() async {
    await _cloud.stopLocalAudio();
    if (_originRole == TRTCCloudDef.TRTCRoleAudience) {
      await _cloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
    } else if (_originRole == TRTCCloudDef.TRTCRoleAnchor) {
      await _cloud.exitRoom();
    }

    if (!_isEmpty(_streamId)) {
      await _cloud.stopPublishing();
    }
  }

  @override
  Future<void> switchCamera(bool isFrontCamera) {
    return _txDeviceManager.switchCamera(isFrontCamera);
  }

  @override
  Future<void> enableCameraTorch(bool enable) {
    return _txDeviceManager.enableCameraTorch(enable);
  }

  @override
  Future<ActionCallback> startCapture({
    int? streamType,
    TRTCVideoEncParam? encParams,
    String appGroup = '',
  }) async {
    if (!_imManager.isEnterRoom) {
      return const ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    _isStartCapture = true;
    await _cloud.startScreenCapture(
      streamType ?? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
      encParams ?? const TRTCVideoEncParam(),
      appGroup: appGroup,
    );
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);

    return const ActionCallback(code: 0, desc: 'startCapture success');
  }

  @override
  Future<void> stopCapture() async {
    await _cloud.stopLocalAudio();
    if (_originRole == TRTCCloudDef.TRTCRoleAudience) {
      await _cloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
    } else if (_originRole == TRTCCloudDef.TRTCRoleAnchor) {
      await _cloud.exitRoom();
    }

    if (_isStartCapture) {
      await _cloud.stopScreenCapture();
    }
  }

  @override
  Future<ActionCallback> startVoice() async {
    if (!_imManager.isEnterRoom) {
      return const ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    _isStartAudio = true;
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);

    return const ActionCallback(code: 0, desc: 'startCapture success');
  }

  @override
  Future<void> stopVoice() async {
    if (_originRole == TRTCCloudDef.TRTCRoleAudience) {
      await _cloud.switchRole(TRTCCloudDef.TRTCRoleAudience);
    } else if (_originRole == TRTCCloudDef.TRTCRoleAnchor) {
      await _cloud.exitRoom();
    }

    if (_isStartAudio) {
      await _cloud.stopLocalAudio();
    }
  }
}
