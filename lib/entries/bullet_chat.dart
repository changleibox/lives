// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:lives/commons/constants.dart';

/// Created by changlei on 2022/1/21.
///
/// 观众，观看的用户
class BulletChat {
  /// 观众，观看的用户
  const BulletChat({
    required this.id,
    this.avatar,
    this.name,
    required this.message,
  });

  /// 从json构建
  factory BulletChat.fromJson(Map<String, dynamic> src) {
    return BulletChat(
      id: src['userID'] as String,
      avatar: src['userAvatar'] as String?,
      name: src['userName'] as String?,
      message: src['message'] as String,
    );
  }

  /// 系统提示
  static const systemTips = BulletChat(id: '', message: systemTipContent);

  /// id
  final String id;

  /// 头像
  final String? avatar;

  /// 昵称
  final String? name;

  /// 消息内容
  final String message;
}
