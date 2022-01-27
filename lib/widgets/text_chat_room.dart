// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/entries/bullet_chat.dart';

/// Created by changlei on 2022/1/25.
///
/// 聊天列表
class TextChatRoom extends StatelessWidget {
  /// 聊天列表
  const TextChatRoom({
    Key? key,
    required this.messages,
  }) : super(key: key);

  /// 聊天列表
  final Iterable<BulletChat> messages;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      margin: const EdgeInsets.only(
        right: 140,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height / 3,
      ),
      child: ListView.separated(
        physics: const ClampingScrollPhysics(),
        reverse: true,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return _ChatItem(
            message: messages.elementAt(index),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(
            height: 10,
          );
        },
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  const _ChatItem({
    Key? key,
    required this.message,
  }) : super(key: key);

  final BulletChat message;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (message == BulletChat.systemTips) {
      child = Text(
        message.message,
        style: TextStyle(
          color: CupertinoTheme.of(context).primaryColor,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: <Shadow>[
            Shadow(
              color: CupertinoColors.black.withOpacity(0.6),
              blurRadius: 4,
            ),
          ],
        ),
      );
    } else {
      child = Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: message.name ?? message.id.toString(),
              style: const TextStyle(
                color: CupertinoColors.activeGreen,
              ),
            ),
            const WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: SizedBox(
                width: 4,
              ),
            ),
            TextSpan(
              text: message.message,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        style: const TextStyle(
          fontSize: 12,
          height: 1.25,
          color: CupertinoColors.white,
        ),
      );
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoColors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        child: child,
      ),
    );
  }
}
