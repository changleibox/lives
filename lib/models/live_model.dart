// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class LiveModel extends LivesModel {
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
  TRTCLiveRoom get room => _LiveProxy.room;

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

  /// 切换摄像头
  Future<void> switchCamera() async {
    final isFont = _isFront;
    if (isFont == null) {
      return;
    }
    await _LiveProxy.switchCamera(_isFront = !isFont);
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
}
