// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/models/live_room_def.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/persistent_header_delegate.dart';
import 'package:lives/widgets/sliver_dynamic_safe_area.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

// Offset from offscreen below to fully on screen.
final _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

/// Created by changlei on 2022/1/18.
///
/// 首页
class HomePage extends StatefulWidget with HostProvider {
  /// 构建首页
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();

  @override
  _HomePresenter createPresenter() => _HomePresenter();
}

class _HomePageState extends HostState<HomePage, _HomePresenter> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      resizeToAvoidBottomInset: false,
      navigationBar: CupertinoNavigationBar(
        middle: const Text('首页'),
        trailing: CupertinoButton(
          minSize: 0,
          padding: EdgeInsets.zero,
          onPressed: presenter._logout,
          child: const Icon(
            CupertinoIcons.escape,
            size: 20,
          ),
        ),
      ),
      child: Center(
        child: WidgetGroup.spacing(
          alignment: MainAxisAlignment.center,
          direction: Axis.vertical,
          spacing: 16,
          children: <Widget>[
            CupertinoButton.filled(
              minSize: 40,
              borderRadius: BorderRadius.circular(6),
              padding: const EdgeInsets.symmetric(
                horizontal: 64,
              ),
              onPressed: presenter._startLive,
              child: const Text('开始直播'),
            ),
            CupertinoButton.filled(
              minSize: 40,
              borderRadius: BorderRadius.circular(6),
              padding: const EdgeInsets.symmetric(
                horizontal: 64,
              ),
              onPressed: presenter._startWatch,
              child: const Text('观看直播'),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomePresenter extends Presenter<HomePage> {
  Future<bool> _checkPermission() async {
    final permissions = await [Permission.camera, Permission.microphone].request();
    if (permissions.values.any((element) => element != PermissionStatus.granted)) {
      showToast('请授权');
      return false;
    }
    return true;
  }

  Future<void> _startLive() async {
    if (!await _checkPermission()) {
      return;
    }
    await Routes.live.pushNamed(
      context,
      arguments: <String, dynamic>{
        'liveType': LiveType.video,
      },
    );
  }

  Future<void> _startWatch() async {
    if (!await _checkPermission()) {
      return;
    }
    final result = await showGeneralDialog<Map<String, dynamic>>(
      context: context,
      barrierLabel: '',
      barrierDismissible: true,
      barrierColor: const CupertinoDynamicColor.withBrightness(
        color: Color(0x33000000),
        darkColor: Color(0x7A000000),
      ),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const _AnchorIdTextField();
      },
    );
    if (result == null) {
      return;
    }
    final anchorId = result['anchorId'] as String?;
    final liveType = result['liveType'] as LiveType?;
    await Routes.watch.pushNamed(
      context,
      arguments: <String, dynamic>{
        'anchorId': anchorId,
        'liveType': liveType,
      },
    );
  }

  Future<void> _logout() async {
    await showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
          content: const Text('您确定要退出当前账号吗？'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('确定'),
              onPressed: () async {
                await FutureWrapper.wrapLoading(
                  context: context,
                  computation: Lives.logout,
                );
                unawaited(Routes.login.pushNamedAndRemoveUntil(context, (route) => false));
              },
            ),
          ],
        );
      },
    );
  }
}

class _AnchorIdTextField extends StatefulWidget {
  const _AnchorIdTextField({Key? key}) : super(key: key);

  @override
  _AnchorIdTextFieldState createState() => _AnchorIdTextFieldState();
}

class _AnchorIdTextFieldState extends State<_AnchorIdTextField> with TickerProviderStateMixin {
  static final _epsilon = Tolerance.defaultTolerance.distance;

  late final _controller = AnimationController(
    duration: const Duration(milliseconds: 335),
    vsync: this,
  );
  late final _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linearToEaseOut,
    reverseCurve: Curves.linearToEaseOut.flipped,
  );

  bool _popped = false;

  @override
  void initState() {
    _controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _controller.reverse();
        return true;
      },
      child: CupertinoUserInterfaceLevel(
        data: CupertinoUserInterfaceLevelData.elevated,
        child: NotificationListener<DraggableScrollableNotification>(
          onNotification: (notification) {
            final extent = notification.extent;
            if (!_popped && nearZero(extent, _epsilon)) {
              Navigator.pop(context);
              _popped = true;
              return false;
            }
            return true;
          },
          child: DraggableScrollableSheet(
            expand: true,
            initialChildSize: 0.5,
            maxChildSize: 1,
            minChildSize: 0,
            snap: true,
            snapSizes: const [0, 0.5, 1],
            builder: (context, scrollController) {
              return SlideTransition(
                position: _kBottomUpTween.animate(_animation),
                child: Container(
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: PrimaryScrollController(
                    controller: scrollController,
                    child: const _LiveRooms(),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LiveRooms extends StatefulWidget {
  const _LiveRooms({Key? key}) : super(key: key);

  @override
  _LiveRoomsState createState() => _LiveRoomsState();
}

class _LiveRoomsState extends CompatibleState<_LiveRooms> {
  final _rooms = <RoomInfo>[];

  bool _isLoading = true;

  @override
  void onPostFrame(Duration timeStamp) {
    _refresh();
    super.onPostFrame(timeStamp);
  }

  Future<void> _refresh() async {
    try {
      final rooms = await Lives.getRooms(List.generate(100, (index) => (index + 1).toString()));
      _rooms.clear();
      _rooms.addAll(rooms.where((element) => element.ownerId != Lives.userId));
    } finally {
      markNeedsBuild(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildItem(BuildContext context, int index) {
    return Container(
      foregroundDecoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: CupertinoColors.separator,
            width: 0,
          ),
        ),
      ),
      child: _RoomInfo(
        room: _rooms[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final navigationBar = CupertinoNavigationBar(
      middle: const Text('正在直播'),
      automaticallyImplyLeading: false,
      padding: EdgeInsetsDirectional.zero,
      trailing: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
        ),
        minSize: 44,
        onPressed: () {
          Navigator.maybePop(context);
        },
        child: const Text(
          '关闭',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
      ),
    );
    final navigationBarHeight = navigationBar.preferredSize.height;
    return CustomScrollView(
      slivers: [
        SliverDynamicSafeArea(
          childHeight: navigationBarHeight,
          builder: (context, padding) {
            final mediaQueryData = MediaQuery.of(context);
            final extent = navigationBarHeight + padding.top;
            return SliverPersistentHeader(
              pinned: true,
              delegate: SizedPersistentHeaderDelegate(
                minExtent: extent,
                maxExtent: extent,
                child: MediaQuery(
                  data: mediaQueryData.copyWith(
                    padding: padding,
                  ),
                  child: navigationBar,
                ),
              ),
            );
          },
        ),
        if (_isLoading || _rooms.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Text(
                _isLoading ? '正在加载～' : '暂无开播的主播噢～',
                style: const TextStyle(
                  color: CupertinoColors.secondaryLabel,
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          SliverSafeArea(
            top: false,
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                _buildItem,
                childCount: _rooms.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _RoomInfo extends StatelessWidget {
  const _RoomInfo({
    Key? key,
    required this.room,
  }) : super(key: key);

  final RoomInfo room;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(10),
      minSize: 0,
      onPressed: () {
        final roomId = room.roomId;
        final anchorId = room.ownerId;
        final liveType = room.liveType;
        Navigator.pop(context, <String, dynamic>{
          'roomId': roomId,
          'anchorId': anchorId,
          'liveType': liveType,
        });
      },
      child: WidgetGroup.spacing(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 1280 / 720,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: CupertinoColors.separator,
                    width: 0,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: room.coverUrl ?? '',
                  width: 1280,
                  height: 720,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: WidgetGroup.spacing(
              alignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              direction: Axis.vertical,
              spacing: 4,
              children: [
                Container(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoTheme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            margin: const EdgeInsets.only(
                              right: 4,
                            ),
                            child: Text(
                              room.liveType.label,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: room.roomName ?? '未知',
                        ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.label,
                    ),
                  ),
                ),
                Text(
                  '主播：${room.ownerName ?? '未知'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                Text(
                  '人数：${room.memberCount}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                Text(
                  '简介：${room.introduction}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
                Text(
                  '通知：${room.notification ?? '暂无～'}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.secondaryLabel,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
