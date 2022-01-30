// Copyright (c) 2022 CHANGLEI. All rights reserved.

// 关键类型定义

// ignore_for_file: public_member_api_docs, sort_constructors_first

class ActionCallback {
  /// 错误码
  final int code;

  /// 信息描述
  final String desc;

  const ActionCallback({this.code = 0, this.desc = ''});
}

class TRTCLiveRoomConfig {
  /// 【字段含义】观众端使用CDN播放
  /// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
  final bool useCDNFirst;

  /// 【字段含义】CDN播放的域名地址
  final String? cdnPlayDomain;

  const TRTCLiveRoomConfig({required this.useCDNFirst, this.cdnPlayDomain});
}

class IMAnchorInfo {
  final String? userId;
  final String? streamId;
  final String? name;

  const IMAnchorInfo({this.userId, this.streamId, this.name});
}

class RoomInfo {
  /// 【字段含义】房间唯一标识
  final String roomId;

  /// 【字段含义】房间名称
  final String? roomName;

  /// 【字段含义】房间封面图
  final String? coverUrl;

  /// 【字段含义】房主id
  final String ownerId;

  /// 【字段含义】房主昵称
  final String? ownerName;

  /// 【字段含义】房间人数
  final int? memberCount;

  /// 简介
  final String? introduction;

  /// 通知
  final String? notification;

  const RoomInfo({
    required this.roomId,
    this.roomName,
    this.coverUrl,
    this.memberCount,
    required this.ownerId,
    this.ownerName,
    this.introduction,
    this.notification,
  });
}

class RoomInfoCallback {
  /// 错误码
  final int code;

  /// 信息描述
  final String desc;

  final List<RoomInfo>? list;

  const RoomInfoCallback({
    required this.code,
    required this.desc,
    this.list,
  });
}

class RoomParam {
  /// 房间名称
  final String roomName;

  /// 房间封面图
  final String? coverUrl;

  /// 音质
  final int? quality;

  /// 简介
  final String? introduction;

  /// 通知
  final String? notification;

  const RoomParam({
    required this.roomName,
    this.coverUrl,
    this.quality,
    this.introduction,
    this.notification,
  });
}

class MemberListCallback {
  /// 错误码
  final int code;

  /// 信息描述
  final String desc;

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  final int nextSeq;

  final List<UserInfo>? list;

  const MemberListCallback({
    this.code = 0,
    this.desc = '',
    this.nextSeq = 0,
    this.list,
  });
}

class UserListCallback {
  /// 错误码
  final int code;

  /// 信息描述
  final String desc;

  /// 用户信息列表
  final List<UserInfo>? list;

  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  final int nextSeq;

  const UserListCallback({
    this.code = 0,
    this.desc = '',
    this.list,
    this.nextSeq = 0,
  });
}

class UserInfo {
  /// 用户唯一标识
  final String userId;

  /// 用户昵称
  final String? userName;

  /// 用户头像
  final String? userAvatar;

  const UserInfo({
    required this.userId,
    this.userName,
    this.userAvatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> src) {
    return UserInfo(
      userId: src['userId'] as String,
      userAvatar: src['userAvatar'] as String?,
      userName: src['userName'] as String?,
    );
  }
}
