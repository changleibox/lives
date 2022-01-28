// Copyright (c) 2022 CHANGLEI. All rights reserved.

library lives;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/entries/bullet_chat.dart';
import 'package:lives/enums/beauty_type.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/helpers/storage.dart';
import 'package:lives/models/live_error.dart';
import 'package:lives/models/live_module.dart';
import 'package:lives/models/live_observer.dart';
import 'package:lives/models/live_room.dart';
import 'package:lives/models/live_room_def.dart';
import 'package:lives/models/live_room_delegate.dart';
import 'package:lives/utils/nums.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';
import 'package:tencent_trtc_cloud/tx_audio_effect_manager.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';

part 'package:lives/models/live_model.dart';

part 'package:lives/models/lives_model.dart';

part 'package:lives/models/watch_model.dart';

const int _sdkAppId = 1400623776;
const int _expireTime = 604800;
const String _secretKey = '4b0cb9f65a743a2e52134f008f963510e0d3716e9af36f6f36fa29863fb7ad19';
const String _userIdKey = 'userId';
const String _signKey = 'sign';
const String _streamId = 'stream';

/// 时间回调
typedef LiveListener = void Function(TRTCLiveRoomDelegate type, Object? params);

/// Created by changlei on 2022/1/20.
///
/// 新版直播
class Lives {
  const Lives._();

  /// 是否已登录
  static bool get isLogged => _LiveProxy.isLogged;

  /// userId
  static String? get userId => _LiveProxy.userId;

  /// 初始化
  static Future<void> setup({bool ignoreException = true}) {
    return _LiveProxy.setup(ignoreException: ignoreException);
  }

  /// 释放
  static Future<void> dispose() {
    return _LiveProxy.dispose();
  }

  /// 登录
  static Future<void> login(String userId) {
    return _LiveProxy.login(
      userId,
      avatar: avatar,
      name: '测试$userId号',
    );
  }

  /// 退出登录
  static Future<void> logout() {
    return _LiveProxy.logout();
  }
}

class _LiveProxy {
  const _LiveProxy._();

  static final _storage = LocalStorage();

  /// 是否已登录
  static bool get isLogged => userId != null;

  /// 登录的userId
  static String? get userId => _storage.get(_userIdKey);

  static late TRTCLiveRoom _room;

  static bool _createdRoom = false;

  static final _listeners = <LiveObserver>{};

  static final _trtcListeners = <ListenerValue>{};

  /// 添加监听
  static void addListener(LiveObserver listener) {
    _listeners.add(listener);
  }

  /// 移除监听
  static void removeListener(LiveObserver listener) {
    _listeners.remove(listener);
  }

  /// 添加监听
  static void addTRTCListener(ListenerValue listener) {
    if (_trtcListeners.isEmpty) {
      _room.addTRTCListener(_trtcEvent);
    }
    _trtcListeners.add(listener);
  }

  /// 移除监听
  static void removeTRTCListener(ListenerValue listener) {
    _trtcListeners.remove(listener);
    if (_trtcListeners.isEmpty) {
      _room.removeTRTCListener(_trtcEvent);
    }
  }

  static void _trtcEvent(TRTCCloudListener type, Object? params) {
    for (var listener in _trtcListeners) {
      listener(type, params);
    }
  }

  /// room
  static TRTCLiveRoom get room => _room;

  /// 获取背景音乐音效管理对象 TXAudioEffectManager。
  static TXAudioEffectManager get audioEffectManager => _room.getAudioEffectManager();

  /// 获取美颜管理对象 TXBeautyManager。
  static TXBeautyManager get beautyManager => _room.getBeautyManager();

  /// 初始化
  static Future<void> setup({bool ignoreException = true}) async {
    try {
      await _storage.setup();
      _room = await TRTCLiveRoom.sharedInstance();
      _room.addListener(_listeners.notify);
      final userId = _LiveProxy.userId;
      if (userId != null) {
        await login(userId);
      }
    } catch (e) {
      if (ignoreException) {
        return;
      }
      rethrow;
    }
  }

  /// 释放
  static Future<void> dispose() async {
    await _storage.dispose();
    _room.removeListener(_listeners.notify);
    await TRTCLiveRoom.destroySharedInstance();
  }

  /// 登录
  static Future<void> login(String userId, {String? name, String? avatar}) async {
    await _storage.set(_userIdKey, userId);
    final sign = _storage.get<String>(_signKey, defaultValue: _generateSign(userId))!;
    await _storage.set(_signKey, sign);
    final callback = await _room.login(_sdkAppId, userId, sign, TRTCLiveRoomConfig(useCDNFirst: false));
    if (callback.code != 0) {
      throw LiveError(callback.code, callback.desc);
    }
    await _room.setSelfProfile(name, avatar);
  }

  /// 退出登录
  static Future<void> logout() async {
    await _storage.remove(_userIdKey);
    await _storage.remove(_signKey);
    await _room.logout();
  }

  /// 开始预览
  static Future<void> startPreview(bool isFront, int viewId) async {
    await _room.startCameraPreview(isFront, viewId);
  }

  /// 停止预览
  static Future<void> stopPreview() async {
    await _room.stopCameraPreview();
  }

  /// 停止预览
  static Future<void> switchCamera(bool isFront) async {
    await _room.switchCamera(isFront);
  }

  /// 开始直播
  static Future<void> startLive(
    int roomId, {
    String? roomName,
    String? cover,
    LiveType type = LiveType.video,
  }) async {
    final callback = await _room.createRoom(
      roomId,
      RoomParam(
        roomName: roomName ?? '',
        coverUrl: cover,
        quality: TRTCCloudDef.TRTC_AUDIO_QUALITY_DEFAULT,
      ),
    );
    if (callback.code != 0) {
      throw LiveError(callback.code, callback.desc);
    }
    _createdRoom = true;
    switch (type) {
      case LiveType.video:
        await _room.startPublish('$_streamId$userId');
        break;
      case LiveType.game:
        await _room.startCapture();
        break;
      case LiveType.voice:
        await _room.startVoice();
        break;
    }
  }

  /// 退出直播
  static Future<void> exitLive({LiveType type = LiveType.video}) async {
    if (!_createdRoom) {
      return;
    }
    switch (type) {
      case LiveType.video:
        await _room.stopPublish();
        break;
      case LiveType.game:
        await _room.stopCapture();
        break;
      case LiveType.voice:
        await _room.stopVoice();
        break;
    }
    final callback = await _room.destroyRoom();
    if (callback.code != 0) {
      throw LiveError(callback.code, callback.desc);
    }
    _createdRoom = false;
  }

  /// 观看直播
  static Future<void> startWatch(String anchorId, int roomId, int viewId) async {
    final callback = await _room.enterRoom(roomId);
    if (callback.code != 0) {
      throw LiveError(callback.code, callback.desc);
    }
    await _room.startPlay(anchorId, viewId);
  }

  /// 停止观看直播
  static Future<void> exitWatch() async {
    final callback = await _room.exitRoom();
    if (callback.code != 0) {
      throw LiveError(callback.code, callback.desc);
    }
  }

  /// 获取直播间信息
  static Future<RoomInfoCallback> getRooms(int roomId) async {
    return await _room.getRoomInfo([roomId.toString()]);
  }

  /// 获取成员信息
  static Future<UserListCallback> getMembers() async {
    return await _room.getRoomMemberInfo(0);
  }

  /// 聊天
  static Future<void> sendMessage(String message) async {
    await _room.sendRoomTextMsg(message);
  }

  static String _generateSign(String userId) {
    final key = utf8.encode(_secretKey);
    final current = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
    final content = 'TLS.identifier:$userId\nTLS.sdkappid:$_sdkAppId\nTLS.time:$current\nTLS.expire:$_expireTime\n';
    final digest = Hmac(sha256, key).convert(utf8.encode(content));
    final sign = base64.encode(digest.bytes);
    final signDoc = <String, dynamic>{
      'TLS.ver': '2.0',
      'TLS.identifier': userId,
      'TLS.sdkappid': _sdkAppId,
      'TLS.expire': _expireTime,
      'TLS.time': current,
      'TLS.sig': sign,
    };
    return base64
        .encode(zlib.encode(utf8.encode(json.encode(signDoc))))
        .replaceAll('\+', '*')
        .replaceAll('\/', '-')
        .replaceAll('=', '_');
  }
}
