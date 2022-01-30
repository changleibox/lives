// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class WatchModel extends LivesModel {
  late String _anchorId;

  @override
  String get _roomId => _anchorId;

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
    _started = true;
    notifyListeners();
  }

  /// 停止观看直播
  Future<void> exitWatch() async {
    _LiveProxy.removeListener(this);
    await _LiveProxy.exitWatch(
      anchorId: _anchorId,
      type: _liveType,
    );
    _started = false;
    notifyListeners();
  }

  @override
  void onRoomDestroy(Object? params) {
    _LiveProxy.removeListener(this);
    super.onRoomDestroy(params);
  }
}
