// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/utils/formats.dart';
import 'package:lives/utils/system_chromes.dart';
import 'package:lives/widgets/beauty.dart';
import 'package:lives/widgets/competition.dart';
import 'package:lives/widgets/income.dart';
import 'package:lives/widgets/interactive_tools.dart';
import 'package:lives/widgets/popularize.dart';
import 'package:lives/widgets/text_chat_room.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:provider/provider.dart';

const _colorGood = Color(0xFF3CFF00);
const _colorBad = Color(0xFFFF0F21);

/// Created by changlei on 2022/1/19.
///
/// 直播覆盖物
class LiveOverlay extends StatefulWidget {
  /// 构建直播覆盖物
  const LiveOverlay({
    Key? key,
    required this.userId,
  }) : super(key: key);

  /// 用户id
  final String userId;

  @override
  _LiveOverlayState createState() => _LiveOverlayState();
}

class _LiveOverlayState extends State<LiveOverlay> {
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
    required this.userId,
  }) : super(key: key);

  /// 用户id
  final String userId;

  @override
  Widget build(BuildContext context) {
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
          child: WidgetGroup.spacing(
            direction: Axis.vertical,
            spacing: 10,
            children: [
              _AppBar(
                userId: userId,
              ),
              const _LiveInfo(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  const _AppBar({
    Key? key,
    required this.userId,
  }) : super(key: key);

  final String userId;

  @override
  Widget build(BuildContext context) {
    return WidgetGroup.spacing(
      spacing: 60,
      children: [
        Expanded(
          child: _UserInfo(
            userId: userId,
          ),
        ),
        CupertinoButton(
          minSize: 32,
          borderRadius: BorderRadius.circular(20),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          color: CupertinoColors.black.withOpacity(0.3),
          child: const Icon(
            CupertinoIcons.arrow_up_bin,
            size: 16,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _LiveInfo extends StatelessWidget {
  const _LiveInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return WidgetGroup.spacing(
      spacing: 10,
      children: [
        CupertinoButton(
          minSize: 20,
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.only(
            left: 10,
            right: 4,
          ),
          color: CupertinoTheme.of(context).primaryColor.withOpacity(0.7),
          child: WidgetGroup.spacing(
            children: const [
              Text(
                '热门榜',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                ),
              ),
              Icon(
                CupertinoIcons.forward,
                size: 16,
              ),
            ],
          ),
          onPressed: () {},
        ),
        Container(
          decoration: ShapeDecoration(
            color: CupertinoTheme.of(context).primaryColor.withOpacity(0.4),
            shape: const StadiumBorder(),
          ),
          height: 20,
          clipBehavior: Clip.antiAlias,
          child: DefaultTextStyle(
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 12,
            ),
            child: WidgetGroup.spacing(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: WidgetGroup.spacing(
                    spacing: 4,
                    children: [
                      const Text('开播分钟'),
                      ValueListenableBuilder<int>(
                        valueListenable: model.clockNotifier,
                        builder: (context, value, child) {
                          return Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: '${value ~/ Duration.secondsPerMinute}/',
                                  style: const TextStyle(
                                    color: CupertinoColors.systemYellow,
                                  ),
                                ),
                                const TextSpan(
                                  text: '15',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                CupertinoButton(
                  color: CupertinoTheme.of(context).primaryColor.withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  minSize: 20,
                  borderRadius: BorderRadius.zero,
                  child: WidgetGroup.spacing(
                    spacing: 2,
                    children: const [
                      Icon(
                        CupertinoIcons.gift_fill,
                        size: 10,
                        color: CupertinoColors.white,
                      ),
                      Text(
                        '流量',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          constraints: const BoxConstraints(
            minWidth: 44,
          ),
          child: WidgetGroup.spacing(
            crossAxisAlignment: CrossAxisAlignment.start,
            direction: Axis.vertical,
            children: [
              ValueListenableBuilder<int>(
                valueListenable: model.networkNotifier,
                builder: (context, quality, child) {
                  final color = quality == 1 ? _colorGood : _colorBad;
                  return ValueListenableBuilder<int>(
                    valueListenable: model.speedNotifier,
                    builder: (context, speed, child) {
                      return WidgetGroup.spacing(
                        spacing: 4,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: color,
                            ),
                            width: 4,
                            height: 4,
                          ),
                          Text(
                            '${Formats.formatMemory(speed)}/s',
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              shadows: const [
                                Shadow(
                                  color: CupertinoColors.black,
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ValueListenableBuilder<int>(
                valueListenable: model.clockNotifier,
                builder: (context, value, child) {
                  return Text(
                    Formats.formatDateTime(
                      DateTime.fromMillisecondsSinceEpoch(
                        value * Duration.millisecondsPerSecond,
                        isUtc: true,
                      ),
                      newPattern: 'HH:mm:ss',
                    )!,
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({
    Key? key,
    required this.userId,
  }) : super(key: key);

  /// 主播id
  final String userId;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    final userInfo = model.getMemberInfo(userId);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        decoration: ShapeDecoration(
          color: CupertinoColors.black.withOpacity(0.3),
          shape: const StadiumBorder(),
        ),
        padding: const EdgeInsets.all(4),
        constraints: const BoxConstraints(
          maxWidth: 200,
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
                    '${model.memberCount}观看｜测试直播·${userId.padLeft(7, '0')}',
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 10,
                    ),
                  ),
                ],
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final portrait = orientation == Orientation.portrait;
    const buttons = _Buttons();
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: WidgetGroup.spacing(
        children: [
          if (portrait)
            const Expanded(
              child: buttons,
            )
          else
            buttons,
          const _BackButton(),
        ],
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  const _Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return Container(
      padding: const EdgeInsets.all(16),
      child: WidgetGroup.spacing(
        spacing: 24,
        children: [
          _OperationButton(
            icon: CupertinoIcons.rectangle_grid_2x2,
            label: '互动工具',
            onPressed: () {
              showInteractiveTools(context);
            },
          ),
          _OperationButton(
            icon: CupertinoIcons.bandage,
            label: '美颜',
            onPressed: () {
              showBeauty(context, model.beautyManager);
            },
          ),
          _OperationButton(
            icon: CupertinoIcons.rotate_right,
            label: '本场收益',
            onPressed: () {
              showIncome(context);
            },
          ),
          _OperationButton(
            icon: CupertinoIcons.arrow_3_trianglepath,
            label: '推广',
            onPressed: () {
              showPopularize(context);
            },
          ),
          _OperationButton(
            icon: CupertinoIcons.app_badge,
            label: 'pk',
            onPressed: () {
              showCompetition(context);
            },
          ),
        ],
      ),
    );
  }
}

class _OperationButton extends StatelessWidget {
  const _OperationButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onPressed,
      child: Icon(
        icon,
        color: CupertinoColors.white,
        size: 26,
        semanticLabel: label,
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    final orientation = MediaQuery.of(context).orientation;
    final portrait = orientation == Orientation.portrait;
    final chatRoom = TextChatRoom(
      messages: model.messages,
    );
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
        bottom: portrait,
        child: Container(
          padding: EdgeInsets.only(
            bottom: portrait ? 0 : 10,
          ),
          child: WidgetGroup.spacing(
            crossAxisAlignment: portrait ? CrossAxisAlignment.stretch : CrossAxisAlignment.end,
            direction: portrait ? Axis.vertical : Axis.horizontal,
            spacing: portrait ? 8 : 24,
            children: [
              if (portrait)
                chatRoom
              else
                Expanded(
                  child: chatRoom,
                ),
              const _LiveOptions(),
            ],
          ),
        ),
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
    return CupertinoButton(
      padding: const EdgeInsets.all(16),
      minSize: 24,
      child: const Icon(
        CupertinoIcons.clear,
        color: CupertinoColors.white,
        size: 24,
      ),
      onPressed: () {
        Navigator.maybePop(context);
      },
    );
  }
}
