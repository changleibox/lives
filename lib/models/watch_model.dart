// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class WatchModel extends LivesModel {
  late String _anchorId;
  late LiveType _liveType;

  @override
  int get _roomId => int.tryParse(_anchorId) ?? 0;

  /// 直播类型
  LiveType get liveType => _liveType;

  @override
  Future<void> setup([String? anchorId, LiveType? liveType]) async {
    _anchorId = anchorId ?? userId;
    _liveType = liveType ?? LiveType.video;
    await super.setup();
  }

  /// 主播id
  String get anchorId {
    assert(mounted, '为初始化');
    return _anchorId;
  }

  /// 观看直播
  Future<void> startWatch([int? viewId]) async {
    _LiveProxy.addListener(this);
    await _LiveProxy.startWatch(
      _anchorId,
      _roomId,
      viewId: viewId,
      type: _liveType,
    );
    _started = true;
    await _refreshRoomInfo();
    await _refreshUserInfo();
    notifyListeners();
  }

  /// 停止观看直播
  Future<void> exitWatch() async {
    _LiveProxy.removeListener(this);
    await _LiveProxy.exitWatch(_anchorId);
    if (!_started) {
      return;
    }
    _started = false;
    notifyListeners();
  }
}
