// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/utils/system_chromes.dart';
import 'package:lives/widgets/text_chat_room.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:provider/provider.dart';

/// Created by changlei on 2022/1/19.
///
/// 观看直播覆盖物
class WatchOverlay extends StatefulWidget {
  /// 构建直播覆盖物
  const WatchOverlay({
    Key? key,
    required this.anchorId,
    required this.userId,
  }) : super(key: key);

  /// 主播id
  final String anchorId;

  /// 用户id
  final String userId;

  @override
  _WatchOverlayState createState() => _WatchOverlayState();
}

class _WatchOverlayState extends State<WatchOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemChromes.liveOverlayStyle,
      child: AnimatedPadding(
        duration: const Duration(
          milliseconds: 250,
        ),
        curve: Curves.easeInOut,
        padding: MediaQuery.of(context).viewInsets,
        child: Stack(
          children: [
            const Positioned.fill(
              top: null,
              child: _BottomBar(),
            ),
            Positioned.fill(
              bottom: null,
              child: _TopBar(
                anchorId: widget.anchorId,
                userId: widget.userId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    Key? key,
    required this.anchorId,
    required this.userId,
  }) : super(key: key);

  /// 主播id
  final String anchorId;

  /// 用户id
  final String userId;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WatchModel>();
    Widget child;
    if (model.started) {
      child = WidgetGroup.spacing(
        spacing: 60,
        children: [
          if (model.started)
            Expanded(
              child: _UserInfo(
                anchorId: anchorId,
              ),
            ),
          if (model.started)
            IntrinsicWidth(
              child: _LiveOptions(
                userId: userId,
              ),
            ),
        ],
      );
    } else {
      child = Container(
        alignment: Alignment.centerLeft,
        height: 40,
        child: const _BackButton(),
      );
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CupertinoColors.black.withOpacity(0.4),
            CupertinoColors.black.withOpacity(0.0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(
        bottom: 20,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: SafeArea(
          bottom: false,
          child: child,
        ),
      ),
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({
    Key? key,
    required this.anchorId,
  }) : super(key: key);

  /// 主播id
  final String anchorId;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WatchModel>();
    final roomInfo = model.roomInfo;
    final userInfo = model.getMemberInfo(anchorId);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: ShapeDecoration(
          color: CupertinoColors.black.withOpacity(0.3),
          shape: const StadiumBorder(),
        ),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        child: WidgetGroup.spacing(
          spacing: 10,
          children: [
            ClipOval(
              clipBehavior: Clip.antiAlias,
              child: CachedNetworkImage(
                imageUrl: userInfo?.userAvatar ?? avatar,
                width: 32,
                height: 32,
              ),
            ),
            Expanded(
              child: WidgetGroup.spacing(
                crossAxisAlignment: CrossAxisAlignment.start,
                direction: Axis.vertical,
                children: [
                  Text(
                    userInfo?.userName ?? userInfo?.userId ?? '直播间',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${model.memberCount}观看｜${roomInfo?.roomName ?? '房主'}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: ShapeDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                shape: const StadiumBorder(),
              ),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                minSize: 32,
                child: const Text(
                  '关注',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white,
                  ),
                ),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveOptions extends StatelessWidget {
  const _LiveOptions({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context) {
    return WidgetGroup.spacing(
      direction: Axis.vertical,
      spacing: 4,
      children: [
        WidgetGroup.spacing(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: ShapeDecoration(
                color: CupertinoColors.black.withOpacity(0.3),
                shape: const CircleBorder(),
              ),
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 24,
                child: const Icon(
                  CupertinoIcons.share,
                  color: CupertinoColors.white,
                  size: 16,
                ),
                onPressed: () {},
              ),
            ),
            const _BackButton(),
          ],
        ),
        Container(
          decoration: ShapeDecoration(
            color: CupertinoColors.black.withOpacity(0.3),
            shape: const StadiumBorder(),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          child: Text(
            '测试直播·${userId.padLeft(7, '0')}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WatchModel>();
    if (!model.started) {
      return const SizedBox();
    }
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            CupertinoColors.black.withOpacity(0.0),
            CupertinoColors.black.withOpacity(0.6),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: SafeArea(
        top: false,
        child: WidgetGroup.spacing(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          direction: Axis.vertical,
          spacing: 8,
          children: [
            TextChatRoom(
              messages: model.messages,
            ),
            const _ChatInput(),
          ],
        ),
      ),
    );
  }
}

class _ChatInput extends StatefulWidget {
  const _ChatInput({
    Key? key,
  }) : super(key: key);

  @override
  State<_ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<_ChatInput> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: WidgetGroup.spacing(
        spacing: 8,
        children: [
          Container(
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: CupertinoTheme.of(context).primaryColor,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: () {},
              child: WidgetGroup(
                direction: Axis.vertical,
                children: const [
                  Icon(
                    CupertinoIcons.brightness,
                    color: CupertinoColors.white,
                    size: 14,
                  ),
                  Text(
                    '66',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 32,
              child: CupertinoTextField(
                controller: _controller,
                placeholder: '聊点什么吧~',
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: CupertinoColors.black.withOpacity(0.2),
                ),
                placeholderStyle: TextStyle(
                  color: CupertinoColors.white.withOpacity(0.6),
                  fontSize: 14,
                ),
                style: const TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 14,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (value) {
                  _controller.clear();
                  context.read<WatchModel>().sendMessage(value);
                },
              ),
            ),
          ),
          Container(
            decoration: ShapeDecoration(
              shape: const CircleBorder(),
              color: CupertinoTheme.of(context).primaryColor,
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 32,
              onPressed: () {},
              child: const Icon(
                CupertinoIcons.ant_fill,
                color: CupertinoColors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: CupertinoColors.black.withOpacity(0.3),
        shape: const CircleBorder(),
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        minSize: 24,
        child: const Icon(
          CupertinoIcons.clear,
          color: CupertinoColors.white,
          size: 16,
        ),
        onPressed: () {
          Navigator.maybePop(context);
        },
      ),
    );
  }
}
