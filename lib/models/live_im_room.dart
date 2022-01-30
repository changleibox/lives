// Copyright (c) 2022 CHANGLEI. All rights reserved.

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
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
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';

const String _logTag = 'TRTCLiveRoomImpl';
const String _requestAnchorCMD = 'requestJoinAnchor'; //请求成为主播信令
const String _kickOutAnchorCMD = 'kickOutJoinAnchor'; //踢出主播信令
const String _requestRoomPKCMD = 'requestRoomPK'; //请求跨房信令
const String _quitRoomPKCMD = 'quitRoomPK'; //退出跨房PK信令
const int _liveCustomCmd = 301;
const int _codeErr = -1;
const int _timeOutCount = 30;

/// 未进入直播间
const notEnterRoomYetError = ActionCallback(code: _codeErr, desc: 'not enter room yet.');

/// FutureOr
typedef FutureOrVoidCallback = FutureOr<void> Function();

/// 事件回调
typedef VoiceListener<P> = void Function(TRTCLiveRoomDelegate type, P params);

/// 自己封装的聊天室工具类
abstract class LiveIMRoom {
  /// 获取 TRTCLiveRoom 单例对象
  /// @return TRTCLiveRoom 实例
  /// @note 可以调用 {@link TRTCLiveRoom.destroySharedInstance()} 销毁单例对象
  static Future<LiveIMRoom> sharedInstance() async {
    return _LiveIMRoom.sharedInstance();
  }

  /// 销毁 TRTCLiveRoom 单例对象
  /// @note 销毁实例后，外部缓存的 TRTCLiveRoom 实例不能再使用，需要重新调用 {@link TRTCLiveRoom.sharedInstance()} 获取新实例
  static Future<void> destroySharedInstance() async {
    await _LiveIMRoom.destroySharedInstance();
  }

  //////////////////////////////////////////////////////////
  //
  //                 基础接口
  //
  //////////////////////////////////////////////////////////

  /// 是否进入
  bool get isEnterRoom;

  /// 登录的用户ID
  String get userId;

  /// trtc相关事件
  void rtcListener(TRTCCloudListener rtcType, Object? param);

  /// 设置组件事件监听接口
  /// 您可以通过 registerListener 获得 TRTCCalling 的各种状态通知
  /// @param VoiceListenerFunc func 回调接口
  void addListener(VoiceListener listener, ValueChanged<bool> callback);

  /// 移除组件事件监听接口
  void removeListener(VoiceListener listener, ValueChanged<bool> callback);

  /// 是否有事件
  bool get hasListeners;

  /// group
  V2TIMGroupManager get groupManager;

  /// signaling
  V2TIMSignalingManager get signalingManager;

  /// 登录
  /// @param sdkAppId 您可以在实时音视频控制台 >【[应用管理](https://console.cloud.tencent.com/trtc/app)】> 应用信息中查看 SDKAppID
  /// @param userId 当前用户的 ID，字符串类型，只允许包含英文字母（a-z 和 A-Z）、数字（0-9）、连词符（-）和下划线（\_）
  /// @param userSig 腾讯云设计的一种安全保护签名，获取方式请参考 [如何计算 UserSig](https://cloud.tencent.com/document/product/647/17275)。
  /// @param 返回值：成功时 code 为0
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig);

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
  Future<ActionCallback> createRoom({
    required String roomId,
    required RoomParam roomParam,
    required FutureOrVoidCallback callback,
    int? scene,
  });

  /// 销毁房间（房间创建者调用）
  /// 主播在创建房间后，可以调用这个函数来销毁房间。
  Future<ActionCallback> destroyRoom(FutureOrVoidCallback callback);

  /// 进入房间（观众调用）
  /// @param roomId 房间标识
  Future<ActionCallback> enterRoom({
    required String roomId,
    int? scene,
    required FutureOrVoidCallback callback,
  });

  /// 退出房间（观众调用）
  Future<ActionCallback> exitRoom(FutureOrVoidCallback callback);

  /// 获取房间列表的详细信息
  /// 其中的信息是主播在创建 createRoom() 时通过 roomInfo 设置进来的，如果房间列表和房间信息都由您的服务器自行管理，此函数您可以不用关心。
  /// @param roomIdList 房间id列表
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIds);

  /// 获取房间内所有的主播列表，enterRoom() 成功后调用才有效。
  Future<UserListCallback> getAnchorInfo();

  /// 获取群成员列表。
  Future<UserListCallback> getRoomMemberInfo(int nextSeq);

  /// 观众请求连麦。
  Future<ActionCallback> requestJoinAnchor();

  /// 主播处理连麦请求。
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree, String callId);

  /// 主播踢除连麦观众。
  Future<ActionCallback> kickOutJoinAnchor(String userId);

  /// 主播请求跨房 PK。
  Future<ActionCallback> requestRoomPK(int roomId, String userId);

  /// 主播响应跨房 PK 请求。
  Future<ActionCallback> responseRoomPK(String userId, bool agree, FutureOrVoidCallback callback);

  /// 退出跨房 PK。
  Future<ActionCallback> quitRoomPK(FutureOrVoidCallback callback);

  /// 在房间中广播文本消息，一般用于弹幕聊天
  /// @param message 文本消息
  Future<ActionCallback> sendRoomTextMsg(String message);

  /// 发送自定义文本消息。
  /// @param cmd 命令字，由开发者自定义，主要用于区分不同消息类型。
  /// @param message 文本消息
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message);
}

/// Created by box on 2022/1/30.
///
/// 处理聊天
class _LiveIMRoom extends LiveIMRoom {
  /// 处理聊天
  _LiveIMRoom() {
    //获取腾讯即时通信IM manager
    _timManager = TencentImSDKPlugin.v2TIMManager;
  }

  static _LiveIMRoom? _instance;

  late final V2TIMManager _timManager;

  final _listeners = <VoiceListener<Object?>>{};

  late String _userId;

  late String _ownerUserId; // 群主用户id

  bool _isInitIMSDK = false;
  bool _isLogin = false;
  bool _isEnterRoom = false; //超时时间，默认30s
  String? _roomIdPK;
  String? _userIdPK;
  String? _roomId;
  String? _selfUserName;
  String? _selfAvatar;
  String _curCallID = '';
  String _curPKCallID = '';
  bool _isPk = false;

  final List<String> _anchorList = [];
  final List<String> _audienceList = [];

  V2TimSignalingListener? _signalingListener;
  V2TimGroupListener? _groupListener;
  V2TimSimpleMsgListener? _simpleMsgListener;

  /// 单例
  static Future<_LiveIMRoom> sharedInstance() async {
    _instance ??= _LiveIMRoom();
    return _instance!;
  }

  /// 释放单例对象
  static Future<void> destroySharedInstance() async {
    if (_instance != null) {
      _instance = null;
    }
  }

  @override
  bool get isEnterRoom => _isEnterRoom;

  @override
  String get userId => _userId;

  @override
  V2TIMGroupManager get groupManager => _timManager.getGroupManager();

  @override
  V2TIMSignalingManager get signalingManager => _timManager.getSignalingManager();

  @override
  Future<ActionCallback> createRoom({
    required String roomId,
    required RoomParam roomParam,
    required FutureOrVoidCallback callback,
    int? scene,
  }) async {
    if (!_isLogin) {
      return const ActionCallback(code: _codeErr, desc: 'im not login yet, create room fail.');
    }
    if (_isEnterRoom) {
      return ActionCallback(
        code: _codeErr,
        desc: 'you have been in room:' + _roomId! + " can't create another room:" + roomId,
      );
    }
    final res = await groupManager.createGroup(
      groupType: 'AVChatRoom',
      groupName: roomParam.roomName,
      groupID: roomId,
      faceUrl: roomParam.coverUrl,
      introduction: roomParam.introduction,
      notification: roomParam.notification,
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
      await callback();

      _anchorList.add(_userId);
      await groupManager.setGroupInfo(
        info: V2TimGroupInfo(
          groupAddOpt: GroupAddOptType.V2TIM_GROUP_ADD_ANY,
          groupID: roomId.toString(),
          groupName: roomParam.roomName,
          faceUrl: roomParam.coverUrl,
          introduction: roomParam.introduction,
          notification: roomParam.notification,
          customInfo: <String, String>{
            'ownerName': _selfUserName ?? '',
          },
          groupType: 'AVChatRoom',
        ),
      );
    }
    return ActionCallback(code: code, desc: msg);
  }

  @override
  Future<ActionCallback> destroyRoom(FutureOrVoidCallback callback) async {
    final dismissRes = await _timManager.dismissGroup(groupID: _roomId!);
    if (dismissRes.code == 0) {
      _destroyData();
      await callback();
      return const ActionCallback(code: 0, desc: 'dismiss room success.');
    } else {
      return const ActionCallback(code: _codeErr, desc: 'dismiss room fail.');
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
  void rtcListener(TRTCCloudListener type, Object? param) {
    switch (type) {
      case TRTCCloudListener.onEnterRoom:
        if ((param as int) < 0) {
          _isEnterRoom = false;
        } else {
          _isEnterRoom = true;
        }
        _emitEvent(TRTCLiveRoomDelegate.onEnterRoom, param);
        break;
      case TRTCCloudListener.onUserVideoAvailable:
        _emitEvent(TRTCLiveRoomDelegate.onUserVideoAvailable, param);
        break;
      case TRTCCloudListener.onError:
        _emitEvent(TRTCLiveRoomDelegate.onError, param);
        break;
      case TRTCCloudListener.onWarning:
        _emitEvent(TRTCLiveRoomDelegate.onWarning, param);
        break;
      case TRTCCloudListener.onUserVoiceVolume:
        // type = TRTCLiveRoomDelegate.onUserVoiceVolume;
        // emitEvent(type, param);
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        _anchorList.add(param as String);
        _emitEvent(TRTCLiveRoomDelegate.onAnchorEnter, param);
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        _anchorList.remove((param as Map)['userId']);
        _emitEvent(TRTCLiveRoomDelegate.onAnchorExit, param['userId']);
        break;
      case TRTCCloudListener.onDisConnectOtherRoom:
        print('==onDisconnectOtherRoom=' + param.toString());
        break;
      case TRTCCloudListener.onStartPublishing:
        print('==onStartPublishing=' + param.toString());
        break;
      default:
        break;
    }
  }

  @override
  Future<ActionCallback> enterRoom({
    required String roomId,
    int? scene,
    required FutureOrVoidCallback callback,
  }) async {
    if (_isEnterRoom) {
      return ActionCallback(
        code: _codeErr,
        desc: 'you have been in room:' + _roomId! + " can't create another room:" + roomId,
      );
    }
    final joinRes = await _timManager.joinGroup(groupID: roomId, message: '');
    if (joinRes.code == 0 || joinRes.code == 10013) {
      _roomId = roomId.toString();
      _isEnterRoom = true;
      await callback();
      final res = await groupManager.getGroupsInfo(groupIDList: [roomId]);
      final groupResult = res.data!;
      _ownerUserId = groupResult[0].groupInfo!.owner!;
    }

    return ActionCallback(code: joinRes.code, desc: joinRes.desc);
  }

  @override
  Future<ActionCallback> exitRoom(FutureOrVoidCallback callback) async {
    if (_roomId == null) {
      return notEnterRoomYetError;
    }
    _destroyData();
    await callback();

    final quitRes = await _timManager.quitGroup(groupID: _roomId!);
    if (quitRes.code != 0) {
      return ActionCallback(code: quitRes.code, desc: quitRes.desc);
    }

    return const ActionCallback(code: 0, desc: 'quit room success.');
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
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIds) async {
    print('==roomIdList=' + roomIds.toString());

    final res = await groupManager.getGroupsInfo(groupIDList: roomIds);
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
            roomId: groupInfo.groupID,
            roomName: groupInfo.groupName,
            coverUrl: groupInfo.faceUrl,
            ownerId: groupInfo.owner!,
            ownerName: groupInfo.customInfo?['ownerName'],
            memberCount: groupInfo.memberCount,
            introduction: groupInfo.introduction,
            notification: groupInfo.notification,
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
      data: jsonEncode(_createCustomMap(_kickOutAnchorCMD)),
      timeout: 0,
      onlineUserOnly: false,
    );
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> login(int sdkAppId, String userId, String userSig) async {
    _userId = userId;

    if (!_isInitIMSDK) {
      //初始化SDK
      final initRes = await _timManager.initSDK(
        sdkAppID: sdkAppId, //填入在控制台上申请的sdkAppId
        loglevel: LogLevelEnum.V2TIM_LOG_ERROR,
        listener: V2TimSDKListener(
          onKickedOffline: () {
            const type = TRTCLiveRoomDelegate.onKickedOffline;
            _emitEvent(type, <String, dynamic>{});
          },
        ),
      );
      if (initRes.code != 0) {
        //初始化sdk错误
        return const ActionCallback(code: 0, desc: 'init im sdk error');
      }
    }
    _isInitIMSDK = true;

    // 登陆到 IM
    var loggedInUserId = (await _timManager.getLoginUser()).data;
    if (loggedInUserId == null || loggedInUserId != userId) {
      loggedInUserId = userId;
      final loginRes = await _timManager.login(
        userID: userId,
        userSig: userSig,
      );
      if (loginRes.code != 0) {
        return ActionCallback(code: _codeErr, desc: loginRes.desc);
      }
    }
    final usersInfo = await _timManager.getUsersInfo(
      userIDList: [loggedInUserId],
    );
    if (usersInfo.code == 0) {
      final info = usersInfo.data?.single;
      _selfAvatar = info?.faceUrl;
      _selfUserName = info?.nickName;
    }
    _isLogin = true;
    return const ActionCallback(code: 0, desc: 'login im success');
  }

  @override
  Future<ActionCallback> logout() async {
    _userId = '';
    _isLogin = false;
    final loginRes = await _timManager.logout();
    return ActionCallback(
      code: loginRes.code,
      desc: loginRes.desc,
    );
  }

  void _emitEvent(TRTCLiveRoomDelegate type, Object? params) {
    for (var listener in _listeners) {
      listener(type, params);
    }
  }

  @override
  Future<ActionCallback> quitRoomPK(FutureOrVoidCallback callback) async {
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: _userIdPK!,
      data: jsonEncode(_createCustomMap(_quitRoomPKCMD)),
      timeout: 0,
      onlineUserOnly: false,
    );
    if (res.code == 0) {
      _isPk = false;
      await callback();
    }
    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  void addListener(VoiceListener listener, ValueChanged<bool> callback) {
    if (_listeners.isEmpty) {
      _signalingListener ??= V2TimSignalingListener(
        onInvitationCancelled: _onInvitationCancelled,
        onInvitationTimeout: _onInvitationTimeout,
        onInviteeAccepted: _onInviteeAccepted,
        onInviteeRejected: _onInviteeRejected,
        onReceiveNewInvitation: _onReceiveNewInvitation,
      );
      //监听im事件
      signalingManager.addSignalingListener(listener: _signalingListener!);
      _groupListener ??= V2TimGroupListener(
        onMemberEnter: _onMemberEnter,
        onMemberLeave: _onMemberLeave,
        onGroupDismissed: _onGroupDismissed,
      );
      _timManager.setGroupListener(listener: _groupListener!);
      _simpleMsgListener ??= V2TimSimpleMsgListener(
        onRecvGroupTextMessage: _onReceiveGroupTextMessage,
        onRecvGroupCustomMessage: _onReceiveGroupCustomMessage,
      );
      _timManager.addSimpleMsgListener(listener: _simpleMsgListener!);
    }
    callback(_listeners.isEmpty);
    _listeners.add(listener);
  }

  @override
  void removeListener(VoiceListener listener, ValueChanged<bool> callback) {
    _listeners.remove(listener);
    if (_listeners.isEmpty) {
      _timManager.removeSimpleMsgListener(listener: _simpleMsgListener);
      _simpleMsgListener = null;
      signalingManager.removeSignalingListener(listener: _signalingListener);
      _signalingListener = null;
    }
    callback(_listeners.isEmpty);
  }

  @override
  bool get hasListeners => _listeners.isNotEmpty;

  @override
  Future<ActionCallback> requestJoinAnchor() async {
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: _ownerUserId,
      data: jsonEncode(_createCustomMap(_requestAnchorCMD)),
      timeout: _timeOutCount,
      onlineUserOnly: false,
    );
    _curCallID = res.data as String;
    return ActionCallback(code: res.code, desc: res.desc);
  }

  Map<String, dynamic> _createCustomMap(String cmd) {
    return <String, dynamic>{
      'version': 1,
      'businessID': 'Live',
      'platform': 'flutter',
      'extInfo': '',
      'data': <String, dynamic>{
        'roomId': _roomId,
        'cmd': cmd,
        'cmdInfo': {
          'userId': _userId,
          'userName': _selfUserName,
          'userAvatar': _selfAvatar,
          'roomId': _roomId,
        },
        'message': ''
      },
    };
  }

  Map<String, dynamic>? _decodeCustomData(String data) {
    try {
      return jsonDecode(data) as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<ActionCallback> requestRoomPK(int roomId, String userId) async {
    if (_anchorList.length >= 2) {
      return const ActionCallback(
        code: _codeErr,
        desc: 'There are two anchors in the room. Cross room calls are not allowed',
      );
    }
    _roomIdPK = roomId.toString();
    _userIdPK = userId;
    final V2TimValueCallback res = await signalingManager.invite(
      invitee: userId,
      data: jsonEncode(_createCustomMap(_requestRoomPKCMD)),
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
      res = await signalingManager.accept(
        inviteID: callId,
        data: jsonEncode(_createCustomMap(_requestAnchorCMD)),
      );
    } else {
      res = await signalingManager.reject(
        inviteID: callId,
        data: jsonEncode(_createCustomMap(_requestAnchorCMD)),
      );
    }

    return ActionCallback(code: res.code, desc: res.desc);
  }

  @override
  Future<ActionCallback> responseRoomPK(String userId, bool agree, FutureOrVoidCallback callback) async {
    V2TimCallback res;
    if (agree) {
      res = await signalingManager.accept(
        inviteID: _curPKCallID,
        data: jsonEncode(_createCustomMap(_requestRoomPKCMD)),
      );
      if (res.code == 0 && _roomIdPK != null) {
        _isPk = true;
        await callback();
      }
    } else {
      res = await signalingManager.reject(
        inviteID: _curPKCallID,
        data: jsonEncode(_createCustomMap(_requestRoomPKCMD)),
      );
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
      return const ActionCallback(code: 0, desc: 'send group message success.');
    } else {
      return ActionCallback(code: res.code, desc: 'send room text fail, not enter room yet.');
    }
  }

  @override
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) async {
    final res = await _timManager.sendGroupCustomMessage(
      customData: jsonEncode({
        'command': cmd,
        'message': message,
        'version': '1.0.0',
        'action': _liveCustomCmd,
      }),
      groupID: _roomId.toString(),
      priority: MessagePriorityEnum.V2TIM_PRIORITY_NORMAL,
    );
    if (res.code == 0) {
      return const ActionCallback(code: 0, desc: 'send group message success.');
    } else {
      return ActionCallback(code: res.code, desc: 'send room custom msg fail, not enter room yet.');
    }
  }

  @override
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL) async {
    _selfUserName = userName;
    _selfAvatar = avatarURL;
    final res = await _timManager.setSelfInfo(
      userFullInfo: V2TimUserFullInfo(
        nickName: userName,
        faceUrl: avatarURL,
      ),
    );
    if (res.code == 0) {
      return const ActionCallback(code: 0, desc: 'set profile success.');
    } else {
      return ActionCallback(code: res.code, desc: 'set profile fail.');
    }
  }

  void _onReceiveGroupCustomMessage(String msgID, String groupID, V2TimGroupMemberInfo sender, String data) {
    final customMap = _decodeCustomData(data);
    if (customMap == null) {
      print(_logTag + 'onReceiveGroupCustomMessage extraMap is null, ignore');
      return;
    }
    final hasAction = customMap.containsKey('action');
    final hasCommand = customMap.containsKey('command');
    final action = customMap['action'] as int?;
    if (hasAction && hasCommand && action == _liveCustomCmd) {
      //群自定义消息
      const type = TRTCLiveRoomDelegate.onReceiveRoomCustomMsg;
      _emitEvent(type, <String, dynamic>{
        'message': customMap['message'],
        'command': customMap['command'],
        'user': {
          'userID': sender.userID,
          'userAvatar': sender.faceUrl,
          'userName': sender.nickName,
        },
      });
    }
  }

  void _onReceiveGroupTextMessage(String msgID, String groupID, V2TimGroupMemberInfo sender, String text) {
    //群文本消息
    _emitEvent(TRTCLiveRoomDelegate.onReceiveRoomTextMsg, <String, dynamic>{
      'message': text,
      'userID': sender.userID,
      'userAvatar': sender.faceUrl,
      'userName': sender.nickName,
    });
  }

  void _onMemberEnter(String groupId, List<V2TimGroupMemberInfo> list) {
    final memberList = list;
    for (var i = 0; i < memberList.length; i++) {
      if (_audienceList.contains(memberList[i].userID)) {
        return;
      }
      _audienceList.add(memberList[i].userID!);
      _emitEvent(TRTCLiveRoomDelegate.onAudienceEnter, {
        'userId': memberList[i].userID,
        'userName': memberList[i].nickName,
        'userAvatar': memberList[i].faceUrl,
      });
    }
  }

  void _onMemberLeave(String groupId, V2TimGroupMemberInfo member) {
    _audienceList.remove(member.userID);
    _emitEvent(TRTCLiveRoomDelegate.onAudienceExit, {
      'userId': member.userID,
      'userName': member.nickName,
      'userAvatar': member.faceUrl,
    });
  }

  void _onGroupDismissed(String groupID, V2TimGroupMemberInfo opUser) {
    //房间被群主解散
    _emitEvent(TRTCLiveRoomDelegate.onRoomDestroy, <String, dynamic>{});
  }

  void _onInvitationCancelled(String inviteID, String inviter, String data) {}

  void _onInvitationTimeout(String inviteID, List<String> inviteeList) {
    if (inviteID == _curCallID || inviteID == _curPKCallID) {
      _emitEvent(TRTCLiveRoomDelegate.onInvitationTimeout, {
        'inviteeList': inviteeList,
      });
    }
  }

  void _onInviteeAccepted(String inviteID, String invitee, String data) {
    if (_userId == invitee) {
      return;
    }
    final customMap = _decodeCustomData(data);
    print('==customMap onInviteeRejected=' + customMap.toString());
    if (customMap == null) {
      print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
      return;
    }
    final hasData = customMap.containsKey('data');
    final customData = customMap['data'] as Map<String, dynamic>?;
    final cmd = customData?['cmd'] as String?;
    if (hasData && cmd == _requestAnchorCMD) {
      _emitEvent(TRTCLiveRoomDelegate.onAnchorAccepted, {
        'userId': invitee,
      });
    } else if (hasData && cmd == _requestRoomPKCMD) {
      _isPk = true;
      _emitEvent(TRTCLiveRoomDelegate.onRoomPKAccepted, {
        'userId': invitee,
      });
    }
  }

  void _onInviteeRejected(String inviteID, String invitee, String data) {
    if (_userId == invitee) {
      return;
    }
    final customMap = _decodeCustomData(data);
    print('==customMap onInviteeRejected=' + customMap.toString());
    if (customMap == null) {
      print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
      return;
    }
    final hasData = customMap.containsKey('data');
    final customData = customMap['data'] as Map<String, dynamic>?;
    final cmd = customData?['cmd'] as String?;
    if (hasData && cmd == _requestAnchorCMD) {
      _emitEvent(TRTCLiveRoomDelegate.onAnchorRejected, {
        'userId': invitee,
      });
    } else if (hasData && cmd == _requestRoomPKCMD) {
      _emitEvent(TRTCLiveRoomDelegate.onRoomPKRejected, {
        'userId': invitee,
      });
    }
  }

  Future<void> _onReceiveNewInvitation(
    String inviteID,
    String inviter,
    String groupID,
    List<String> inviteeList,
    String data,
  ) async {
    final customMap = _decodeCustomData(data);
    print('==customMap=' + customMap.toString());

    if (customMap == null) {
      print(_logTag + 'onReceiveNewInvitation extraMap is null, ignore');
      return;
    }

    final hasData = customMap.containsKey('data');
    final customData = customMap['data'] as Map<String, dynamic>?;
    final cmd = customData?['cmd'] as String?;
    final cmdInfo = customData?['cmdInfo'] as Map<String, dynamic>?;
    final userName = cmdInfo?['userName'] as String?;
    final userAvatar = cmdInfo?['userAvatar'] as String?;
    if (hasData && cmd == _requestAnchorCMD) {
      if (_isPk) {
        //在pk通话中，直接拒绝观众的主播请求
        await signalingManager.reject(
          inviteID: inviteID,
          data: jsonEncode(_createCustomMap(_requestAnchorCMD)),
        );
      } else {
        _curCallID = inviteID;
        _emitEvent(TRTCLiveRoomDelegate.onRequestJoinAnchor, <String, dynamic>{
          'userId': inviter,
          'userName': userName,
          'userAvatar': userAvatar,
          'callId': inviteID,
        });
      }
    } else if (hasData && cmd == _kickOutAnchorCMD) {
      _curCallID = inviteID;
      _emitEvent(TRTCLiveRoomDelegate.onKickOutJoinAnchor, <String, dynamic>{
        'userId': inviter,
        'userName': userName,
        'userAvatar': userAvatar,
      });
    } else if (hasData && cmd == _requestRoomPKCMD) {
      // 当前有两个主播直接拒绝跨房通话
      if (_anchorList.length >= 2) {
        await signalingManager.reject(
          inviteID: inviteID,
          data: jsonEncode(_createCustomMap(_requestRoomPKCMD)),
        );
      } else {
        _curPKCallID = inviteID;
        _userIdPK = inviter;
        _roomIdPK = cmdInfo?['roomId'] as String?;
        _emitEvent(TRTCLiveRoomDelegate.onRequestRoomPK, <String, dynamic>{
          'userId': inviter,
          'userName': userName,
          'userAvatar': userAvatar,
        });
      }
    } else if (hasData && cmd == _quitRoomPKCMD) {
      _isPk = false;
      _emitEvent(TRTCLiveRoomDelegate.onQuitRoomPK, {
        'userId': inviter,
      });
    }
  }
}
