// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of 'lives.dart';

/// Created by changlei on 2022/1/25.
///
/// 直播基类
abstract class LivesModel extends ChangeNotifier with LiveObserver {
  final _messages = Queue<BulletChat>();
  final _listeners = <VoidCallback>{};

  RoomInfo? _roomInfo;
  Map<String, UserInfo>? _memberInfo;
  bool _mounted = false;
  bool _started = false;
  int _memberCount = 0;

  /// 初始化
  Future<void> setup() async {
    _mounted = true;
    _setupMessages();
    notifyListeners();
  }

  /// 是否开始直播或者观看直播
  bool get started => _started;

  /// 是否已经初始化
  bool get mounted => _mounted;

  /// 当前登录用户id
  String get userId => _LiveProxy.userId!;

  int get _roomId => int.tryParse(userId) ?? 0;

  /// 房间信息
  RoomInfo? get roomInfo => _roomInfo;

  /// 主播信息
  UserInfo? getMemberInfo(String userId) => _memberInfo?[userId];

  /// 成员数量
  int get memberCount => _memberCount;

  /// 监听直播间解散
  void addDestroyListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// 删除直播间解散监听
  void removeDestroyListener(VoidCallback listener) {
    _listeners.remove(listener);
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

  Future<void> _refreshRoomInfo() async {
    final roomCallback = await _LiveProxy.getRooms(_roomId);
    final rooms = roomCallback.list;
    Map<int, RoomInfo>? roomMap;
    if (rooms != null && rooms.isNotEmpty) {
      roomMap = Map.fromEntries(rooms.map((e) => MapEntry(e.roomId, e)));
    }
    _roomInfo = roomMap?[_roomId];
  }

  Future<void> _refreshUserInfo() async {
    final userCallback = await _LiveProxy.getMembers();
    final users = userCallback.list;
    Map<String, UserInfo>? userMap;
    if (users != null && users.isNotEmpty) {
      userMap = Map.fromEntries(users.map((e) => MapEntry(e.userId, e)));
    }
    _memberInfo = userMap;
    _memberCount = userMap?.length ?? 0;
  }

  Future<void> _onMemberEnterExit(UserInfo member, String message) async {
    if (member.userId == userId) {
      return;
    }
    _addBulletChar(
      message: message,
      userId: member.userId,
      userName: member.userName,
      userAvatar: member.userAvatar,
    );
    await _refreshRoomInfo();
    await _refreshUserInfo();
    notifyListeners();
  }

  @override
  void onReceiveRoomTextMsg(BulletChat bulletChat) {
    _messages.addFirst(bulletChat);
    notifyListeners();
    super.onReceiveRoomTextMsg(bulletChat);
  }

  @override
  void onAudienceEnter(UserInfo userInfo) {
    _onMemberEnterExit(userInfo, '进入直播间');
    super.onAudienceEnter(userInfo);
  }

  @override
  void onAudienceExit(UserInfo userInfo) {
    _onMemberEnterExit(userInfo, '离开直播间');
    super.onAudienceExit(userInfo);
  }

  @override
  void onRoomDestroy(Object? params) {
    _started = false;
    for (var listener in _listeners) {
      listener();
    }
    notifyListeners();
    super.onRoomDestroy(params);
  }
}
