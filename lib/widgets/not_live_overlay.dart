// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/utils/system_chromes.dart';
import 'package:lives/widgets/beauty.dart';
import 'package:lives/widgets/more.dart';
import 'package:lives/widgets/popularize.dart';
import 'package:lives/widgets/share.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

const _animationDuration = Duration(
  milliseconds: 150,
);

/// Created by changlei on 2022/1/19.
///
/// 直播覆盖物
class NotLiveOverlay extends StatefulWidget {
  /// 构建直播覆盖物
  const NotLiveOverlay({
    Key? key,
    required this.userId,
    required this.onStart,
  }) : super(key: key);

  /// 用户id
  final String userId;

  /// 点击开始
  final VoidCallback onStart;

  @override
  _NotLiveOverlayState createState() => _NotLiveOverlayState();
}

class _NotLiveOverlayState extends State<NotLiveOverlay> {
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemChromes.liveOverlayStyle,
      child: AnimatedPadding(
        duration: const Duration(
          milliseconds: 300,
        ),
        curve: Curves.easeInOut,
        padding: MediaQuery.of(context).viewInsets,
        child: Stack(
          children: [
            Positioned.fill(
              top: null,
              child: _BottomBar(
                onStart: widget.onStart,
              ),
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
          vertical: 8,
        ),
        child: SafeArea(
          bottom: false,
          child: WidgetGroup.spacing(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            direction: Axis.vertical,
            spacing: 16,
            children: const [
              _AppBar(),
              _RoomInfo(),
              _Advertisement(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppBar extends StatefulWidget {
  const _AppBar({
    Key? key,
  }) : super(key: key);

  @override
  State<_AppBar> createState() => _AppBarState();
}

class _AppBarState extends State<_AppBar> {
  Widget _buildItem(LiveType value, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      child: AnimatedDefaultTextStyle(
        duration: _animationDuration,
        style: TextStyle(
          color: CupertinoColors.white.withOpacity(selected ? 1 : 0.5),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        child: AnimatedScale(
          duration: _animationDuration,
          scale: selected ? 1.0 : 0.95,
          child: Text(value.label),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return Container(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 0,
            child: _BackButton(),
          ),
          Positioned(
            right: 0,
            child: CupertinoButton(
              minSize: 0,
              padding: const EdgeInsets.all(16),
              onPressed: () {},
              child: WidgetGroup.spacing(
                spacing: 2,
                children: const [
                  Icon(
                    CupertinoIcons.person,
                    size: 14,
                    color: CupertinoColors.white,
                  ),
                  Text(
                    '主播中心',
                    style: TextStyle(
                      color: CupertinoColors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            child: CupertinoSegmentedControl<LiveType>(
              pressedColor: CupertinoColors.white.withOpacity(0),
              borderColor: CupertinoColors.white.withOpacity(0),
              selectedColor: CupertinoColors.white.withOpacity(0),
              unselectedColor: CupertinoColors.white.withOpacity(0),
              groupValue: model.liveType,
              onValueChanged: (value) {
                model.liveType = value;
              },
              children: Map.fromEntries(LiveType.values.map((e) {
                return MapEntry(e, _buildItem(e, e == model.liveType));
              })),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomInfo extends StatelessWidget {
  const _RoomInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return Container(
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: WidgetGroup.spacing(
        spacing: 10,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            clipBehavior: Clip.antiAlias,
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minSize: 0,
              onPressed: () {},
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: model.roomCover,
                    width: 80,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                  Positioned.fill(
                    top: null,
                    child: Container(
                      alignment: Alignment.center,
                      color: CupertinoColors.black.withOpacity(0.6),
                      height: 16,
                      child: const Text(
                        '更换封面',
                        style: TextStyle(
                          color: CupertinoColors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: WidgetGroup.spacing(
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.vertical,
              spacing: 12,
              children: [
                WidgetGroup.spacing(
                  children: [
                    Flexible(
                      child: Text(
                        model.roomName,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          height: 1,
                          color: CupertinoColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    CupertinoButton(
                      onPressed: () {},
                      minSize: 20,
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        CupertinoIcons.pencil_outline,
                        size: 12,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
                WidgetGroup.spacing(
                  spacing: 12,
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: CupertinoColors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        minSize: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        alignment: Alignment.centerLeft,
                        child: WidgetGroup.spacing(
                          spacing: 4,
                          children: [
                            const Icon(
                              CupertinoIcons.square_list,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            Flexible(
                              child: Text(
                                model.liveType.theme,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                    Expanded(
                      child: CupertinoButton(
                        color: CupertinoColors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        minSize: 22,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                        ),
                        alignment: Alignment.centerLeft,
                        child: WidgetGroup.spacing(
                          spacing: 4,
                          children: const [
                            Icon(
                              CupertinoIcons.waveform_path,
                              size: 12,
                              color: CupertinoColors.white,
                            ),
                            Flexible(
                              child: Text(
                                '选择话题',
                                style: TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Advertisement extends StatelessWidget {
  const _Advertisement({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: CupertinoButton(
        color: CupertinoColors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        padding: const EdgeInsets.all(8),
        minSize: 0,
        onPressed: () {},
        child: WidgetGroup.spacing(
          spacing: 8,
          children: const [
            Icon(
              CupertinoIcons.bookmark_fill,
              size: 16,
              color: CupertinoColors.systemRed,
            ),
            Expanded(
              child: Text(
                '新人任务奖励2500曝光，扶持期至02月06日！',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 12,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.forward,
              size: 18,
              color: CupertinoColors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    Key? key,
    required this.onStart,
  }) : super(key: key);

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
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
        bottom: 56,
      ),
      child: SafeArea(
        top: false,
        child: WidgetGroup.spacing(
          direction: Axis.vertical,
          spacing: 16,
          children: [
            const _LiveOperators(),
            _StartLiveButton(
              onStart: onStart,
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveOperators extends StatelessWidget {
  const _LiveOperators({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return Container(
      alignment: Alignment.center,
      child: WidgetGroup(
        mainAxisSize: MainAxisSize.min,
        children: [
          _OperationButton(
            icon: CupertinoIcons.rectangle_expand_vertical,
            label: '直播推广',
            onPressed: () {
              showPopularize(context);
            },
          ),
          if (model.liveType == LiveType.video)
            _OperationButton(
              icon: CupertinoIcons.camera_rotate,
              label: '翻转',
              onPressed: () {
                model.switchCamera();
              },
            ),
          if (model.liveType == LiveType.video)
            _OperationButton(
              icon: CupertinoIcons.bandage,
              label: '美颜',
              onPressed: () {
                showBeauty(context, model.beautyManager);
              },
            ),
          if (model.liveType == LiveType.game)
            _OperationButton(
              icon: CupertinoIcons.device_phone_landscape,
              label: '横屏',
              onPressed: () {
                showToast('您选择的游戏为横屏');
              },
            ),
          if (model.liveType == LiveType.game)
            _OperationButton(
              icon: CupertinoIcons.app,
              label: '投屏',
              onPressed: () {},
            ),
          if (model.liveType == LiveType.voice)
            _OperationButton(
              icon: CupertinoIcons.tv,
              label: '背景',
              onPressed: () {},
            ),
          _OperationButton(
            icon: CupertinoIcons.share,
            label: '分享',
            onPressed: () {
              showShare(context);
            },
          ),
          _OperationButton(
            icon: CupertinoIcons.ellipsis_circle,
            label: '更多',
            onPressed: () {
              showMore(context);
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
      minSize: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      onPressed: onPressed,
      child: WidgetGroup.spacing(
        direction: Axis.vertical,
        spacing: 8,
        children: [
          Icon(
            icon,
            color: CupertinoColors.white,
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StartLiveButton extends StatelessWidget {
  const _StartLiveButton({
    Key? key,
    required this.onStart,
  }) : super(key: key);

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LiveModel>();
    return WidgetGroup.spacing(
      direction: Axis.vertical,
      spacing: 24,
      children: [
        Container(
          decoration: ShapeDecoration(
            color: CupertinoTheme.of(context).primaryColor,
            shape: const StadiumBorder(),
          ),
          clipBehavior: Clip.antiAlias,
          child: CupertinoButton(
            onPressed: onStart,
            minSize: 40,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            borderRadius: BorderRadius.circular(24),
            child: WidgetGroup.spacing(
              mainAxisSize: MainAxisSize.min,
              spacing: 4,
              children: [
                const Icon(
                  CupertinoIcons.play_rectangle_fill,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                Text(
                  '开始${model.liveType.label}直播',
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Text(
          '开通即代表同意《管家婆云直播协议》',
          style: TextStyle(
            fontSize: 12,
            color: CupertinoColors.white,
          ),
        ),
      ],
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
