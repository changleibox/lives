// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class LiveModel extends LivesModel implements LiveModule {
  final _speedNotifier = ValueNotifier<int>(0);
  final _clockNotifier = ValueNotifier<int>(0);
  final _networkNotifier = ValueNotifier<int>(1);

  /// 网速
  ValueListenable<int> get speedNotifier => _speedNotifier;

  /// 时间流逝
  ValueListenable<int> get clockNotifier => _clockNotifier;

  /// 网络质量
  ValueListenable<int> get networkNotifier => _networkNotifier;

  /// room
  TRTCLiveRoom get _room => _LiveProxy.room;

  /// 获取背景音乐音效管理对象 TXAudioEffectManager。
  TXAudioEffectManager get audioEffectManager => _LiveProxy.audioEffectManager;

  /// 获取美颜管理对象 TXBeautyManager。
  TXBeautyManager get beautyManager => _LiveProxy.beautyManager;

  Timer? _timer;
  int? _viewId;
  bool? _isFront;
  int _lastSendBytes = 0;

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
    );
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
    await _LiveProxy.exitLive();
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
  Future<void> enableCameraTorch(bool enable) {
    return _room.enableCameraTorch(enable);
  }

  @override
  Future<UserListCallback> getAnchorInfo() {
    return _room.getAnchorInfo();
  }

  @override
  TXAudioEffectManager getAudioEffectManager() {
    return _room.getAudioEffectManager();
  }

  @override
  TXBeautyManager getBeautyManager() {
    return _room.getBeautyManager();
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
  Future<void> muteAllRemoteAudio(bool mute) {
    return _room.muteAllRemoteAudio(mute);
  }

  @override
  Future<void> muteLocalAudio(bool mute) {
    return _room.muteLocalAudio(mute);
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
  Future<ActionCallback> sendRoomTextMsg(String message) {
    return _room.sendRoomTextMsg(message);
  }

  @override
  Future<void> setMirror(bool isMirror) {
    return _room.setMirror(isMirror);
  }

  @override
  Future<ActionCallback> setSelfProfile(String? userName, String? avatarURL) {
    return _room.setSelfProfile(userName, avatarURL);
  }

  @override
  Future<void> startCameraPreview(bool isFrontCamera, int viewId) {
    return _room.startCameraPreview(isFrontCamera, viewId);
  }

  @override
  Future<void> startPlay(String userId, int viewId) {
    return _room.startPlay(userId, viewId);
  }

  @override
  Future<void> startPublish(String? streamId) {
    return _room.startPublish(streamId);
  }

  @override
  Future<void> stopCameraPreview() {
    return _room.stopCameraPreview();
  }

  @override
  Future<void> stopPlay(String userId) {
    return _room.stopPlay(userId);
  }

  @override
  Future<void> stopPublish() {
    return _room.stopPublish();
  }

  @override
  Future<void> updateLocalView(int viewId) {
    return _room.updateLocalView(viewId);
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
  }
}
