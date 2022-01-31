// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class WatchModel extends LivesModel {
  late String _anchorId;

  RoomInfo? _roomInfo;

  @override
  String get _roomId => _anchorId;

  /// 房间信息
  RoomInfo? get roomInfo => _roomInfo;

  @override
  Future<void> setup([LiveType? liveType, String? anchorId]) {
    _anchorId = anchorId ?? userId;
    return super.setup(liveType);
  }

  /// 主播id
  String get anchorId {
    assert(mounted, '未初始化');
    return _anchorId;
  }

  /// 观看直播
  Future<void> startWatch([int? viewId]) async {
    _LiveProxy.addListener(this);
    await _LiveProxy.startWatch(
      anchorId: _anchorId,
      roomId: _roomId,
      viewId: viewId,
      type: _liveType,
    );
    await _refreshRoomInfo();
    await _refreshUserInfo();
    started = true;
    notifyListeners();
  }

  /// 停止观看直播
  Future<void> exitWatch() async {
    _LiveProxy.removeListener(this);
    await _LiveProxy.exitWatch(
      anchorId: _anchorId,
      type: _liveType,
    );
    started = false;
    notifyListeners();
  }

  @override
  void onRoomDestroy(Object? params) {
    _LiveProxy.removeListener(this);
    super.onRoomDestroy(params);
  }

  Future<void> _refreshRoomInfo() async {
    _roomInfo = await _LiveProxy.getRoom(_roomId);
  }

  @override
  Future<void> onMemberChanged(UserInfo member) async {
    await _refreshRoomInfo();
    await super.onMemberChanged(member);
  }
}
