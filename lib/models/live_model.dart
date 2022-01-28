// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class LiveModel extends LivesModel implements LiveModule {
  final _speedNotifier = ValueNotifier<int>(0);
  final _clockNotifier = ValueNotifier<int>(0);
  final _networkNotifier = ValueNotifier<int>(1);
  final _beautyValue = <BeautyType, int>{
    BeautyType.smooth: 6,
    BeautyType.nature: 6,
    BeautyType.pitu: 6,
    BeautyType.whitening: 0,
    BeautyType.ruddy: 0,
  };

  Timer? _timer;
  int? _viewId;
  bool? _isFront;
  int _lastSendBytes = 0;
  bool _enableTorch = false;
  bool _isMirror = false;
  bool _localMute = false;
  bool _remoteMute = false;
  LiveType _liveType = LiveType.video;

  /// 直播类型
  LiveType get liveType => _liveType;

  set liveType(LiveType value) {
    assert(!started);
    if (value == liveType) {
      return;
    }
    _liveType = value;
    switch (value) {
      case LiveType.video:
        if (_isFront != null && _viewId != null) {
          startPreview(_isFront!, _viewId!);
        }
        break;
      case LiveType.game:
        stopPreview();
        break;
      case LiveType.voice:
        stopPreview();
        break;
    }
    notifyListeners();
  }

  /// 网速
  ValueListenable<int> get speedNotifier => _speedNotifier;

  /// 时间流逝
  ValueListenable<int> get clockNotifier => _clockNotifier;

  /// 网络质量
  ValueListenable<int> get networkNotifier => _networkNotifier;

  /// room
  TRTCLiveRoom get _room => _LiveProxy.room;

  @override
  TXAudioEffectManager get audioEffectManager => _LiveProxy.audioEffectManager;

  @override
  TXBeautyManager get beautyManager => _LiveProxy.beautyManager;

  /// 获取美颜数据
  Map<BeautyType, int> get beauty => Map.unmodifiable(_beautyValue);

  /// 设置美颜数据
  set beauty(Map<BeautyType, int> value) {
    if (mapEquals(value, _beautyValue)) {
      return;
    }
    _beautyValue.addAll(value);
    notifyListeners();
  }

  /// 是否为前置摄像头，null为为开启预览
  bool? get isFront => _isFront;

  /// 是否开启闪光灯
  bool get enableTorch => _enableTorch;

  /// 是否镜像显示
  bool get isMirror => _isMirror;

  /// 本地是否静音
  bool get localMute => _localMute;

  /// 远程是否静音
  bool get remoteMute => _remoteMute;

  void _startDownTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (timer) {
      _clockNotifier.value = timer.tick;
    });
  }

  void _stopDownTimer() {
    _timer?.cancel();
    _timer = null;
    _clockNotifier.value = 0;
  }

  /// 开始预览
  Future<void> startPreview(bool isFront, int viewId) {
    _isFront = isFront;
    _viewId = viewId;
    return _LiveProxy.startPreview(isFront, viewId);
  }

  /// 开始预览
  Future<void> stopPreview() {
    _isFront = null;
    _viewId = null;
    return _LiveProxy.stopPreview();
  }

  /// 开始直播
  Future<void> startLive({String? roomName, String? cover}) async {
    _LiveProxy.addListener(this);
    _LiveProxy.addTRTCListener(_onEvent);
    if (_isFront != null && _viewId != null) {
      await startPreview(_isFront!, _viewId!);
    }
    await _LiveProxy.startLive(
      _roomId,
      roomName: '我在火星',
      cover: cover,
      appGroup: 'group.me.box.lives',
      type: _liveType,
    );
    _setupMessages();
    _startDownTimer();
    _started = true;
    await _refreshRoomInfo();
    await _refreshUserInfo();
    notifyListeners();
  }

  /// 退出直播
  Future<void> exitLive() async {
    _LiveProxy.removeListener(this);
    _LiveProxy.removeTRTCListener(_onEvent);
    await _LiveProxy.exitLive(
      type: _liveType,
    );
    if (_isFront != null && _viewId != null) {
      await startPreview(_isFront!, _viewId!);
    }
    _speedNotifier.value = 0;
    _lastSendBytes = 0;
    _networkNotifier.value = 1;
    _stopDownTimer();
    if (!_started) {
      return;
    }
    _started = false;
    notifyListeners();
  }

  void _onEvent(TRTCCloudListener type, Object? params) {
    if (type == TRTCCloudListener.onStatistics) {
      final sendBytes = parseInt(
        (params as Map<String, dynamic>)['sendBytes'],
        defaultValue: 0,
      )!;
      _speedNotifier.value = max(sendBytes - _lastSendBytes, 0) ~/ 2;
      _lastSendBytes = sendBytes;
    } else if (type == TRTCCloudListener.onNetworkQuality) {
      final localQuality = (params as Map<String, dynamic>)['localQuality'] as Map<String, dynamic>;
      _networkNotifier.value = parseInt(localQuality['quality'], defaultValue: 0)!;
    }
  }

  @override
  Future<void> enableCameraTorch() async {
    await _room.enableCameraTorch(_enableTorch = !_enableTorch);
    notifyListeners();
  }

  @override
  Future<UserListCallback> getAnchorInfo() {
    return _room.getAnchorInfo();
  }

  @override
  Future<RoomInfoCallback> getRoomInfo(List<String> roomIds) {
    return _room.getRoomInfo(roomIds);
  }

  @override
  Future<UserListCallback> getRoomMemberInfo(int nextSeq) {
    return _room.getRoomMemberInfo(nextSeq);
  }

  @override
  Future<ActionCallback> kickOutJoinAnchor(String userId) {
    return _room.kickOutJoinAnchor(userId);
  }

  @override
  Future<void> muteAllRemoteAudio() async {
    await _room.muteAllRemoteAudio(_remoteMute = !_remoteMute);
    notifyListeners();
  }

  @override
  Future<void> muteLocalAudio() async {
    await _room.muteLocalAudio(_localMute = !_localMute);
    notifyListeners();
  }

  @override
  Future<void> muteRemoteAudio(String userId, bool mute) {
    return _room.muteRemoteAudio(userId, mute);
  }

  @override
  Future<ActionCallback> quitRoomPK() {
    return _room.quitRoomPK();
  }

  @override
  Future<ActionCallback> requestJoinAnchor() {
    return _room.requestJoinAnchor();
  }

  @override
  Future<ActionCallback> requestRoomPK(int roomId, String userId) {
    return _room.requestRoomPK(roomId, userId);
  }

  @override
  Future<ActionCallback> responseJoinAnchor(String userId, bool agree, String callId) {
    return _room.responseJoinAnchor(userId, agree, callId);
  }

  @override
  Future<ActionCallback> responseRoomPK(String userId, bool agree) {
    return _room.responseRoomPK(userId, agree);
  }

  @override
  Future<ActionCallback> sendRoomCustomMsg(String cmd, String message) {
    return _room.sendRoomCustomMsg(cmd, message);
  }

  @override
  Future<void> setMirror() async {
    await _room.setMirror(_isMirror = !_isMirror);
    notifyListeners();
  }

  @override
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL) {
    return _room.setSelfProfile(userName, avatarURL);
  }

  @override
  Future<void> updateLocalView() async {
    if (_viewId == null) {
      return;
    }
    return _room.updateLocalView(_viewId!);
  }

  @override
  Future<void> updateRemoteView(String userId, int viewId) {
    return _room.updateRemoteView(userId, viewId);
  }

  @override
  Future<void> switchCamera() async {
    final isFont = _isFront;
    if (isFont == null) {
      return;
    }
    await _LiveProxy.switchCamera(_isFront = !isFont);
    notifyListeners();
  }
}
