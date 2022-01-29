// Copyright (c) 2022 CHANGLEI. All rights reserved.

// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:lives/models/live_room_def.dart';
import 'package:lives/models/live_room_delegate.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimGroupListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSignalingListener.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_group_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_signaling_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';
import 'package:tencent_trtc_cloud/tx_device_manager.dart';

const String _logTag = 'TRTCLiveRoomImpl';
const String _requestAnchorCMD = 'requestJoinAnchor'; //请求成为主播信令
const String _kickOutAnchorCMD = 'kickOutJoinAnchor'; //踢出主播信令
const String _requestRoomPKCMD = 'requestRoomPK'; //请求跨房信令
const String _quitRoomPKCMD = 'quitRoomPK'; //退出跨房PK信令
const int _liveCustomCmd = 301;
const int _codeErr = -1;
const int _timeOutCount = 30;

/// 事件回调
typedef VoiceListener<P> = void Function(TRTCLiveRoomDelegate type, P params);

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
  _TRTCLiveRoom() {
    //获取腾讯即时通信IM manager
    _timManager = TencentImSDKPlugin.v2TIMManager;
  }

  static _TRTCLiveRoom? _instance;

  late final V2TIMManager _timManager;
  late final TRTCCloud _cloud;
  late final TXAudioEffectManager _txAudioManager;
  late final TXDeviceManager _txDeviceManager;

  final Set<VoiceListener> _listeners = {};
  final Set<ListenerValue> _trtcListeners = {};

  late int _sdkAppId;
  late String _userId;
  late String _userSig;

  late String _ownerUserId; // 群主用户id
  late int _originRole;

  bool _isInitIMSDK = false;
  bool _isLogin = false;
  bool _isEnterRoom = false; //超时时间，默认30s
  String? _roomIdPK;
  String? _userIdPK;
  String? _roomId;
  String? _selfUserName;
  String? _selfAvatar;
  String? _streamId;
  String _curCallID = '';
  String _curPKCallID = '';
  bool _isPk = false;
  bool _isStartCapture = false;
  bool _isStartAudio = false;

  // ignore: unused_field
  TRTCLiveRoomConfig? _roomConfig;

  final List<String> _anchorList = [];
  final List<String> _audienceList = [];

  Future<void> _initTRTC() async {
    _cloud = (await TRTCCloud.sharedInstance())!;
    _txDeviceManager = _cloud.getDeviceManager();
    _txAudioManager = _cloud.getAudioEffectManager();
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
  }

  V2TIMGroupManager get groupManager => _timManager.getGroupManager();

  V2TIMSignalingManager get signalingManager => _timManager.getSignalingManager();

  TXAudioEffectManager get audioEffectManager => _txAudioManager;

  @override
  Future<ActionCallback> createRoom(int roomId, RoomParam roomParam, {int? scene}) async {
    if (!_isLogin) {
      return ActionCallback(code: _codeErr, desc: 'im not login yet, create room fail.');
    }
    if (_isEnterRoom) {
      return ActionCallback(
        code: _codeErr,
        desc: 'you have been in room:' + _roomId! + " can't create another room:" + roomId.toString(),
      );
    }
    final res = await groupManager.createGroup(
      groupType: 'AVChatRoom',
      groupName: roomParam.roomName,
      groupID: roomId.toString(),
    );
    var msg = res.desc;
    var code = res.code;
    if (code == 0) {
      msg = 'create room success';
    } else if (code == 10036) {
      msg =
          '您当前使用的云通讯账号未开通音视频聊天室功能，创建聊天室数量超过限额，请前往腾讯云官网开通【IM音视频聊天室】，地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10037) {
      msg = '单个用户可创建和加入的群组数量超过了限制，请购买相关套餐,价格地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10038) {
      msg = '群成员数量超过限制，请参考，请购买相关套餐，价格地址：https://cloud.tencent.com/document/product/269/11673';
    } else if (code == 10025 || code == 10021) {
      // 10025 表明群主是自己，那么认为创建房间成功
      // 群组 ID 已被其他人使用，此时走进房逻辑
      final joinRes = await _timManager.joinGroup(groupID: roomId.toString(), message: '');
      if (joinRes.code == 0) {
        code = 0;
        msg = 'group has been created.join group success.';
      } else {
        code = joinRes.code;
        msg = joinRes.desc;
      }
    }
    //setGroupInfo
    if (code == 0) {
      _roomId = roomId.toString();
      _isEnterRoom = true;
      _originRole = TRTCCloudDef.TRTCRoleAnchor;
      await _cloud.enterRoom(
        TRTCParams(
          sdkAppId: _sdkAppId,
          //应用Id
          userId: _userId,
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

      // mAnchorList.add(IMAnchorInfo(
      //     userId: mUserId, name: mSelfUserName, streamId: mStreamId));
      _anchorList.add(_userId);
      await groupManager.setGroupInfo(
        info: V2TimGroupInfo(
          groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
          groupID: roomId.toString(),
          groupName: roomParam.roomName,
          faceUrl: roomParam.coverUrl,
          introduction: _selfUserName,
          groupType: 'AVChatRoom',
        ),
      );
    }
    return ActionCallback(code: code, desc: msg);
  }

  @override
  Future<ActionCallback> destroyRoom() async {
    final dismissRes = await _timManager.dismissGroup(groupID: _roomId!);
    if (dismissRes.code == 0) {
      _destroyData();
      await _cloud.exitRoom();
      return ActionCallback(code: 0, desc: 'dismiss room success.');
    } else {
      return ActionCallback(code: _codeErr, desc: 'dismiss room fail.');
    }
  }

  void _destroyData() {
    _isEnterRoom = false;
    _isPk = false;
    _curCallID = '';
    _curPKCallID = '';
    _anchorList.clear();
  }

  @override
  Future<ActionCallback> enterRoom(int roomId, {int? scene}) async {
    if (_isEnterRoom) {
      return ActionCallback(
        code: _codeErr,
        desc: 'you have been in room:' + _roomId! + " can't create another room:" + roomId.toString(),
      );
    }
    final joinRes = await _timManager.joinGroup(groupID: roomId.toString(), message: '');
    if (joinRes.code == 0 || joinRes.code == 10013) {
      _roomId = roomId.toString();
      _isEnterRoom = true;
      _originRole = TRTCCloudDef.TRTCRoleAudience;
      await _cloud.enterRoom(
        TRTCParams(
          sdkAppId: _sdkAppId,
          //应用Id
          userId: _userId,
          // 用户Id
          userSig: _userSig,
          // 用户签名
          role: TRTCCloudDef.TRTCRoleAudience,
          roomId: roomId,
        ),
        scene ?? TRTCCloudDef.TRTC_APP_SCENE_LIVE,
      );
      final res = await groupManager.getGroupsInfo(groupIDList: [roomId.toString()]);
      final groupResult = res.data!;
      _ownerUserId = groupResult[0].groupInfo!.owner!;
    }

    return ActionCallback(code: joinRes.code, desc: joinRes.desc);
  }

  @override
  Future<ActionCallback> exitRoom() async {
    if (_roomId == null) {
      return ActionCallback(code: _codeErr, desc: 'not enter room yet');
    }
    _destroyData();
    await _cloud.exitRoom();

    final quitRes = await _timManager.quitGroup(groupID: _roomId!);
    if (quitRes.code != 0) {
      return ActionCallback(code: quitRes.code, desc: quitRes.desc);
    }

    return ActionCallback(code: 0, desc: 'quit room success.');
  }

  @override
  Future<UserListCallback> getAnchorInfo() async {
    final res = await _timManager.getUsersInfo(userIDList: _anchorList);

    if (res.code == 0) {
      final userInfo = res.data!;
      final newInfo = <UserInfo>[];
      for (var i = 0; i < userInfo.length; i++) {
        newInfo.add(
          UserInfo(
            userId: userInfo[i].userID!,
            userName: userInfo[i].nickName!,
            userAvatar: userInfo[i].faceUrl!,
          ),
        );
      }
      return UserListCallback(code: 0, desc: 'get anchorInfo success.', list: newInfo);
    } else {
      return UserListCallback(code: res.code, desc: res.desc);
    }
  }

  @override
  Future<UserListCallback> getRoomMemberInfo(int nextSeq) async {
    print('==nextSeq=' + nextSeq.toString());
    print('==mRoomId=' + _roomId.toString());
    final memberRes = await groupManager.getGroupMemberList(
      groupID: _roomId!,
      filter: GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL,
      nextSeq: nextSeq.toString(),
    );
    if (memberRes.code != 0) {
      return UserListCallback(code: memberRes.code, desc: memberRes.desc);
    }
    final memberInfoList = memberRes.data!.memberInfoList!;
    final newInfo = <UserInfo>[];
    for (var i = 0; i < memberInfoList.length; i++) {
      newInfo.add(
        UserInfo(
          userId: memberInfoList[i]!.userID,
          userName: memberInfoList[i]!.nickName,
          userAvatar: memberInfoList[i]!.faceUrl,
        ),
      );
    }
    return UserListCallback(
      code: 0,
      desc: 'get member list success',
      nextSeq: int.parse(memberRes.data!.nextSeq!),
      list: newInfo,
    );
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
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIdList) async {
    print('==roomIdList=' + roomIdList.toString());

    final res = await groupManager.getGroupsInfo(groupIDList: roomIdList);
    if (res.code != 0) {
      return RoomInfoCallback(code: res.code, desc: res.desc);
    }

    final listInfo = res.data!;

    final newInfo = <RoomInfo>[];
    for (var i = 0; i < listInfo.length; i++) {
      print(listInfo[i].toJson());
      if (listInfo[i].resultCode == 0) {
        //兼容获取不到群id信息的情况
        final groupInfo = listInfo[i].groupInfo!;
        newInfo.add(
          RoomInfo(
            roomId: int.parse(groupInfo.groupID),
            roomName: groupInfo.groupName,
            coverUrl: groupInfo.faceUrl,
            ownerId: groupInfo.owner!,
            ownerName: groupInfo.introduction,
            memberCount: groupInfo.memberCount,
          ),
        );
      }
    }

    return RoomInfoCallback(code: 0, desc: 'getRoomInfoList success', list: newInfo);
  }

  @override
  Future<ActionCallback> kickOutJoinAnchor(String userId) async {
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: userId,
      data: jsonEncode(_getCustomMap(_kickOutAnchorCMD)),
      timeout: 0,
      onlineUserOnly: false,
    );
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig, TRTCLiveRoomConfig config) async {
    _sdkAppId = sdkAppId;
    _userId = userId;
    _userSig = userSig;
    _roomConfig = config;

    if (!_isInitIMSDK) {
      //初始化SDK
      final initRes = await _timManager.initSDK(
        sdkAppID: sdkAppId, //填入在控制台上申请的sdkAppId
        loglevel: LogLevelEnum.V2TIM_LOG_ERROR,
        listener: V2TimSDKListener(
          onKickedOffline: () {
            const type = TRTCLiveRoomDelegate.onKickedOffline;
            emitEvent(type, <String, dynamic>{});
          },
        ),
      );
      if (initRes.code != 0) {
        //初始化sdk错误
        return ActionCallback(code: 0, desc: 'init im sdk error');
      }
    }
    _isInitIMSDK = true;

    // 登陆到 IM
    final loggedInUserId = (await _timManager.getLoginUser()).data;

    if (loggedInUserId != null && loggedInUserId == userId) {
      _isLogin = true;
      return ActionCallback(code: 0, desc: 'login im success');
    }
    final loginRes = await _timManager.login(userID: userId, userSig: userSig);
    if (loginRes.code == 0) {
      _isLogin = true;
      return ActionCallback(code: 0, desc: 'login im success');
    } else {
      return ActionCallback(code: _codeErr, desc: loginRes.desc);
    }
  }

  @override
  Future<ActionCallback> logout() async {
    _sdkAppId = 0;
    _userId = '';
    _userSig = '';
    _isLogin = false;
    final loginRes = await _timManager.logout();
    return ActionCallback(code: loginRes.code, desc: loginRes.desc);
  }

  void emitEvent(TRTCLiveRoomDelegate type, dynamic params) {
    for (var item in _listeners) {
      item(type, params);
    }
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
  Future<ActionCallback> quitRoomPK() async {
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: _userIdPK!,
      data: jsonEncode(_getCustomMap(_quitRoomPKCMD)),
      timeout: 0,
      onlineUserOnly: false,
    );
    if (res.code == 0) {
      _isPk = false;
      //退出跨房通话
      await _cloud.disconnectOtherRoom();
    }
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  void addListener(VoiceListener listener) {
    if (_listeners.isEmpty) {
      //监听im事件
      signalingManager.addSignalingListener(listener: _signalingListener);
      _timManager.setGroupListener(listener: _groupListener);
      _timManager.addSimpleMsgListener(listener: _simpleMsgListener);
    }
    if (_trtcListeners.isEmpty && _listeners.isEmpty) {
      //监听trtc事件
      _cloud.registerListener(_trtcListener);
    }
    _listeners.add(listener);
  }

  @override
  void removeListener(VoiceListener listener) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _timManager.removeSimpleMsgListener();
      signalingManager.removeSignalingListener(listener: _signalingListener);
    }
    if (_trtcListeners.isEmpty && _listeners.isEmpty) {
      _cloud.unRegisterListener(_trtcListener);
    }
  }

  @override
  void addTRTCListener(ListenerValue listener) {
    if (_trtcListeners.isEmpty && _listeners.isEmpty) {
      //监听trtc事件
      _cloud.registerListener(_trtcListener);
    }
    _trtcListeners.add(listener);
  }

  @override
  void removeTRTCListener(ListenerValue listener) {
    _trtcListeners.remove(_trtcListeners);
    if (_trtcListeners.isEmpty && _listeners.isEmpty) {
      _cloud.unRegisterListener(_trtcListener);
    }
  }

  // im 相关事件绑定
  V2TimSimpleMsgListener get _simpleMsgListener {
    TRTCLiveRoomDelegate type;
    return V2TimSimpleMsgListener(
      onRecvGroupCustomMessage: (msgID, groupID, sender, customData) {
        try {
          final customMap = jsonDecode(customData) as Map<String, dynamic>?;
          if (customMap == null) {
            print(_logTag + 'onReceiveGroupCustomMessage extraMap is null, ignore');
            return;
          }
          if (customMap.containsKey('action') &&
              customMap.containsKey('command') &&
              customMap['action'] == _liveCustomCmd) {
            //群自定义消息
            type = TRTCLiveRoomDelegate.onReceiveRoomCustomMsg;
            emitEvent(type, <String, dynamic>{
              'message': customMap['message'],
              'command': customMap['command'],
              'user': {
                'userID': sender.userID,
                'userAvatar': sender.faceUrl,
                'userName': sender.nickName,
              },
            });
          }
        } catch (e) {
          print(_logTag + ' onReceiveGroupCustomMessage error log.' + e.toString());
        }
      },
      onRecvGroupTextMessage: (msgID, groupID, sender, text) {
        //群文本消息
        type = TRTCLiveRoomDelegate.onReceiveRoomTextMsg;
        emitEvent(type, {
          'message': text,
          'userID': sender.userID,
          'userAvatar': sender.faceUrl,
          'userName': sender.nickName,
        });
      },
    );
  }

  // trtc相关事件
  void _trtcListener(TRTCCloudListener rtcType, Object? param) {
    var typeStr = rtcType.toString();
    TRTCLiveRoomDelegate type;
    typeStr = typeStr.replaceFirst('TRTCCloudListener.', '');
    if (typeStr == 'onEnterRoom') {
      if ((param as int) < 0) {
        _isEnterRoom = false;
      } else {
        _isEnterRoom = true;
      }
    } else if (typeStr == 'onUserVideoAvailable') {
      type = TRTCLiveRoomDelegate.onUserVideoAvailable;
      emitEvent(type, param);
    } else if (typeStr == 'onError') {
      type = TRTCLiveRoomDelegate.onError;
      emitEvent(type, param);
    } else if (typeStr == 'onWarning') {
      type = TRTCLiveRoomDelegate.onWarning;
      emitEvent(type, param);
    } else if (typeStr == 'onUserVoiceVolume') {
      // type = TRTCLiveRoomDelegate.onUserVoiceVolume;
      // emitEvent(type, param);
    } else if (typeStr == 'onRemoteUserEnterRoom') {
      // updateMixConfig();
      _anchorList.add(param as String);
      type = TRTCLiveRoomDelegate.onAnchorEnter;
      emitEvent(type, param);
    } else if (typeStr == 'onRemoteUserLeaveRoom') {
      // updateMixConfig();
      _anchorList.remove((param as Map)['userId']);
      type = TRTCLiveRoomDelegate.onAnchorExit;
      emitEvent(type, param['userId']);
    } else if (typeStr == 'onDisconnectOtherRoom') {
      print('==onDisconnectOtherRoom=' + param.toString());
    } else if (typeStr == 'onStartPublishing') {
      print('==onStartPublishing=' + param.toString());
    }
    for (var trtcListener in _trtcListeners) {
      trtcListener(rtcType, param);
    }
  }

  // im群事件绑定
  V2TimGroupListener get _groupListener {
    TRTCLiveRoomDelegate type;
    return V2TimGroupListener(
      onMemberEnter: (String groupId, List<V2TimGroupMemberInfo> list) {
        type = TRTCLiveRoomDelegate.onAudienceEnter;
        final memberList = list;
        for (var i = 0; i < memberList.length; i++) {
          if (_audienceList.contains(memberList[i].userID)) {
            return;
          }
          _audienceList.add(memberList[i].userID!);
          emitEvent(type, {
            'userId': memberList[i].userID,
            'userName': memberList[i].nickName,
            'userAvatar': memberList[i].faceUrl
          });
        }
      },
      onMemberLeave: (String groupId, V2TimGroupMemberInfo member) {
        _audienceList.remove(member.userID);
        type = TRTCLiveRoomDelegate.onAudienceExit;
        emitEvent(type, {'userId': member.userID, 'userName': member.nickName, 'userAvatar': member.faceUrl});
      },
      onGroupDismissed: (groupID, opUser) {
        //房间被群主解散
        type = TRTCLiveRoomDelegate.onRoomDestroy;
        emitEvent(type, <String, dynamic>{});
      },
    );
  }

  //im信令事件绑定
  V2TimSignalingListener get _signalingListener {
    return V2TimSignalingListener(
      onInvitationCancelled: (inviteID, inviter, data) {},
      onInvitationTimeout: (inviteID, inviteeList) {
        if (inviteID == _curCallID || inviteID == _curPKCallID) {
          emitEvent(TRTCLiveRoomDelegate.onInvitationTimeout, {
            'inviteeList': inviteeList,
          });
        }
      },
      onInviteeAccepted: (inviteID, invitee, data) {
        if (_userId == invitee) {
          return;
        }
        try {
          final customMap = jsonDecode(data) as Map<String, dynamic>?;
          print('==customMap onInviteeRejected=' + customMap.toString());
          if (customMap == null) {
            print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
            return;
          }
          if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestAnchorCMD) {
            emitEvent(TRTCLiveRoomDelegate.onAnchorAccepted, {
              'userId': invitee,
            });
          } else if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestRoomPKCMD) {
            _isPk = true;
            emitEvent(TRTCLiveRoomDelegate.onRoomPKAccepted, {
              'userId': invitee,
            });
          }
        } catch (e) {
          print(_logTag + ' signalingListener error log.');
        }
      },
      onInviteeRejected: (inviteID, invitee, data) {
        if (_userId == invitee) {
          return;
        }
        try {
          final customMap = jsonDecode(data) as Map<String, dynamic>?;
          print('==customMap onInviteeRejected=' + customMap.toString());
          if (customMap == null) {
            print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
            return;
          }
          if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestAnchorCMD) {
            emitEvent(TRTCLiveRoomDelegate.onAnchorRejected, {
              'userId': invitee,
            });
          } else if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestRoomPKCMD) {
            emitEvent(TRTCLiveRoomDelegate.onRoomPKRejected, {
              'userId': invitee,
            });
          }
        } catch (e) {
          print(_logTag + ' signalingListener error log.');
        }
      },
      onReceiveNewInvitation: (inviteID, inviter, groupID, inviteeList, data) async {
        try {
          final customMap = jsonDecode(data) as Map<String, dynamic>?;
          print('==customMap=' + customMap.toString());

          if (customMap == null) {
            print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
            return;
          }

          if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestAnchorCMD) {
            if (_isPk) {
              //在pk通话中，直接拒绝观众的主播请求
              await signalingManager.reject(inviteID: inviteID, data: jsonEncode(_getCustomMap(_requestAnchorCMD)));
            } else {
              _curCallID = inviteID;
              emitEvent(TRTCLiveRoomDelegate.onRequestJoinAnchor, <String, dynamic>{
                'userId': inviter,
                'userName': customMap['data']['cmdInfo']['userName'],
                'userAvatar': customMap['data']['cmdInfo']['userAvatar'],
                'callId': inviteID
              });
            }
          } else if (customMap.containsKey('data') && customMap['data']['cmd'] == _kickOutAnchorCMD) {
            _curCallID = inviteID;
            emitEvent(TRTCLiveRoomDelegate.onKickOutJoinAnchor, <String, dynamic>{
              'userId': inviter,
              'userName': customMap['data']['cmdInfo']['userName'],
              'userAvatar': customMap['data']['cmdInfo']['userAvatar'],
            });
          } else if (customMap.containsKey('data') && customMap['data']['cmd'] == _requestRoomPKCMD) {
            // 当前有两个主播直接拒绝跨房通话
            if (_anchorList.length >= 2) {
              await signalingManager.reject(inviteID: inviteID, data: jsonEncode(_getCustomMap(_requestRoomPKCMD)));
            } else {
              _curPKCallID = inviteID;
              _userIdPK = inviter;
              _roomIdPK = customMap['data']['cmdInfo']['roomId'] as String?;
              emitEvent(TRTCLiveRoomDelegate.onRequestRoomPK, <String, dynamic>{
                'userId': inviter,
                'userName': customMap['data']['cmdInfo']['userName'],
                'userAvatar': customMap['data']['cmdInfo']['userAvatar'],
              });
            }
          } else if (customMap.containsKey('data') && customMap['data']['cmd'] == _quitRoomPKCMD) {
            _isPk = false;
            emitEvent(TRTCLiveRoomDelegate.onQuitRoomPK, {
              'userId': inviter,
            });
          }
        } catch (e) {
          print(_logTag + ' signalingListener error log.');
        }
      },
    );
  }

  @override
  Future<ActionCallback> requestJoinAnchor() async {
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: _ownerUserId,
      data: jsonEncode(_getCustomMap(_requestAnchorCMD)),
      timeout: _timeOutCount,
      onlineUserOnly: false,
    );
    _curCallID = res.data as String;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  Map<String, dynamic> _getCustomMap(String cmd) {
    final customMap = <String, dynamic>{};
    customMap['version'] = 1;
    customMap['businessID'] = 'Live';
    customMap['platform'] = 'flutter';
    customMap['extInfo'] = '';
    customMap['data'] = {
      'roomId': _roomId,
      'cmd': cmd,
      'cmdInfo': {
        'userId': _userId,
        'userName': _selfUserName,
        'userAvatar': _selfAvatar,
        'roomId': _roomId,
      },
      'message': ''
    };
    return customMap;
  }

  @override
  Future<ActionCallback> requestRoomPK(int roomId, String userId) async {
    if (_anchorList.length >= 2) {
      return ActionCallback(
          code: _codeErr, desc: 'There are two anchors in the room. Cross room calls are not allowed');
    }
    _roomIdPK = roomId.toString();
    _userIdPK = userId;
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: userId,
      data: jsonEncode(_getCustomMap(_requestRoomPKCMD)),
      timeout: _timeOutCount,
      onlineUserOnly: false,
    );
    _curPKCallID = res.data as String;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree, String callId) async {
    V2TimCallback res;
    if (agree) {
      res = await signalingManager.accept(inviteID: callId, data: jsonEncode(_getCustomMap(_requestAnchorCMD)));
    } else {
      res = await signalingManager.reject(inviteID: callId, data: jsonEncode(_getCustomMap(_requestAnchorCMD)));
    }

    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> responseRoomPK(String userId, bool agree) async {
    V2TimCallback res;
    if (agree) {
      res = await signalingManager.accept(inviteID: _curPKCallID, data: jsonEncode(_getCustomMap(_requestRoomPKCMD)));
      if (res.code == 0 && _roomIdPK != null) {
        _isPk = true;
        await _cloud.connectOtherRoom(jsonEncode({'roomId': int.parse(_roomIdPK!), 'userId': userId}));
      }
    } else {
      res = await signalingManager.reject(inviteID: _curPKCallID, data: jsonEncode(_getCustomMap(_requestRoomPKCMD)));
    }

    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> sendRoomTextMsg(String message) async {
    final res = await _timManager.sendGroupTextMessage(
      text: message,
      groupID: _roomId.toString(),
      priority: MessagePriority.V2TIM_PRIORITY_NORMAL,
    );
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'send group message success.');
    } else {
      return ActionCallback(code: res.code, desc: 'send room text fail, not enter room yet.');
    }
  }

  @override
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) async {
    final res = await _timManager.sendGroupCustomMessage(
      customData: jsonEncode({'command': cmd, 'message': message, 'version': '1.0.0', 'action': _liveCustomCmd}),
      groupID: _roomId.toString(),
      priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    );
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'send group message success.');
    } else {
      return ActionCallback(code: res.code, desc: 'send room custom msg fail, not enter room yet.');
    }
  }

  @override
  Future<void> setMirror(bool isMirror) {
    if (isMirror) {
      return _cloud.setLocalRenderParams(TRTCRenderParams(mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_ENABLE));
    } else {
      return _cloud.setLocalRenderParams(TRTCRenderParams(mirrorType: TRTCCloudDef.TRTC_VIDEO_MIRROR_TYPE_DISABLE));
    }
  }

  @override
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL) async {
    _selfUserName = userName;
    _selfAvatar = avatarURL;
    final res = await _timManager.setSelfInfo(userFullInfo: V2TimUserFullInfo(nickName: userName, faceUrl: avatarURL));
    if (res.code == 0) {
      return ActionCallback(code: 0, desc: 'set profile success.');
    } else {
      return ActionCallback(code: res.code, desc: 'set profile fail.');
    }
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
    if (!_isEnterRoom) {
      return ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    await _handleVideoEncoderParams();
    if (!_isEmpty(streamId)) {
      _streamId = streamId;
      await _cloud.startPublishing(streamId!, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
    }
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT);

    return ActionCallback(code: 0, desc: 'startPublish success');
  }

  Future<void> _handleVideoEncoderParams() async {
    // 如果是观众，那么则切换到主播
    if (_originRole == TRTCCloudDef.TRTCRoleAudience) {
      await _cloud.switchRole(TRTCCloudDef.TRTCRoleAnchor);
      // 观众切换到主播是小主播，小主播设置一下分辨率
      final param = TRTCVideoEncParam();
      param.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_480_270;
      param.videoBitrate = 400;
      param.videoFps = 15;
      param.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
      await _cloud.setVideoEncoderParam(param);
    } else if (_originRole == TRTCCloudDef.TRTCRoleAnchor) {
      // 大主播的时候切换分辨率
      final param = TRTCVideoEncParam();
      param.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_1280_720;
      param.videoBitrate = 1800;
      param.videoFps = 15;
      param.enableAdjustRes = true;
      param.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
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
    if (!_isEnterRoom) {
      return ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    _isStartCapture = true;
    await _cloud.startScreenCapture(
      streamType ?? TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG,
      encParams ?? TRTCVideoEncParam(),
      appGroup: appGroup,
    );
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);

    return ActionCallback(code: 0, desc: 'startCapture success');
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
    if (!_isEnterRoom) {
      return ActionCallback(code: _codeErr, desc: 'not enter room yet.');
    }
    _isStartAudio = true;
    await _cloud.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_MUSIC);

    return ActionCallback(code: 0, desc: 'startCapture success');
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
