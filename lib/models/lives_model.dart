// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/25.
///
/// 直播基类
abstract class LivesModel extends ChangeNotifier with LiveObserver {
  final _messages = Queue<BulletChat>();

  final _destroyNotifier = ValueNotifier<bool>(false);
  final _startedNotifier = ValueNotifier<bool>(false);

  LiveType _liveType = LiveType.video;

  bool _mounted = false;
  Map<String, UserInfo>? _memberInfo;
  Completer<void>? _pendingCompleter;

  /// 初始化
  Future<void> setup({LiveType? liveType}) async {
    _liveType = liveType ?? LiveType.video;
    _mounted = true;
    _setupMessages();
    notifyListeners();
  }

  /// 直播类型
  LiveType get liveType => _liveType;

  @mustCallSuper
  set liveType(LiveType value) {
    assert(!started);
    if (value == liveType) {
      return;
    }
    _liveType = value;
    notifyListeners();
  }

  /// 释放房间通知
  ValueNotifier<bool> get destroyNotifier => _destroyNotifier;

  /// 开始通知
  ValueNotifier<bool> get startedNotifier => _startedNotifier;

  /// 是否开始直播或者观看直播
  bool get started => startedNotifier.value;

  /// 设置是否开始
  set started(bool value) => _startedNotifier.value = value;

  /// 是否已经初始化
  bool get mounted => _mounted;

  /// 当前登录用户id
  String get userId => _LiveProxy.userId!;

  String get _roomId => userId;

  /// 主播信息
  UserInfo? getMemberInfo(String userId) => _memberInfo?[userId];

  /// 成员数量
  int get memberCount => _memberInfo?.length ?? 0;

  Future<void> _startPendingLive([FutureOr<void> Function()? onTimeout]) async {
    final pendingCompleter = Completer<void>();
    _pendingCompleter = pendingCompleter;
    var timeout = false;
    await pendingCompleter.future.timeout(
      _timeLimit,
      onTimeout: () async {
        await onTimeout?.call();
        timeout = true;
      },
    );
    if (timeout) {
      throw TimeoutException('等待超时，请稍后再试');
    }
    timeout = false;
  }

  void _stopPendingLive() {
    _pendingCompleter?.complete();
    _pendingCompleter = null;
  }

  /// 消息列表
  List<BulletChat> get messages => List.unmodifiable(_messages);

  /// 初始化消息列表
  void _setupMessages() {
    _messages.clear();
    _messages.add(BulletChat.systemTips);
  }

  /// 发送消息
  Future<void> sendMessage(String message) async {
    message = message.trimRight();
    if (message.isEmpty) {
      return;
    }
    await _LiveProxy.sendMessage(message);
    final member = getMemberInfo(userId);
    _addBulletChar(
      userId: userId,
      message: message,
      userAvatar: member?.userAvatar,
      userName: member?.userName,
    );
    notifyListeners();
  }

  void _addBulletChar({
    required String userId,
    required String message,
    String? userName,
    String? userAvatar,
  }) {
    _messages.addFirst(BulletChat(
      id: userId,
      message: message,
      name: userName,
      avatar: userAvatar,
    ));
  }

  Future<void> _refreshUserInfo() async {
    _memberInfo = await _LiveProxy.getMembers();
  }

  Future<void> _onMemberEnterExit(UserInfo member, String message) async {
    if (member.userId != userId) {
      _addBulletChar(
        message: message,
        userId: member.userId,
        userName: member.userName,
        userAvatar: member.userAvatar,
      );
    }
    await onMemberChanged(member);
  }

  /// 成员发生变化
  @protected
  @mustCallSuper
  Future<void> onMemberChanged(UserInfo member) async {
    await _refreshUserInfo();
    notifyListeners();
  }

  @override
  void onReceiveRoomTextMsg(BulletChat bulletChat) {
    if (started) {
      _messages.addFirst(bulletChat);
      notifyListeners();
    }
    super.onReceiveRoomTextMsg(bulletChat);
  }

  @override
  void onAudienceEnter(UserInfo userInfo) {
    if (started) {
      _onMemberEnterExit(userInfo, '进入直播间');
    }
    super.onAudienceEnter(userInfo);
  }

  @override
  void onAudienceExit(UserInfo userInfo) {
    if (started) {
      _onMemberEnterExit(userInfo, '离开直播间');
    }
    super.onAudienceExit(userInfo);
  }

  @override
  void onRoomDestroy(Object? params) {
    started = false;
    _destroyNotifier.value = true;
    if (_mounted) {
      notifyListeners();
    }
    super.onRoomDestroy(params);
  }

  @override
  void dispose() {
    _mounted = false;
    notifyListeners();
    super.dispose();
  }
}
