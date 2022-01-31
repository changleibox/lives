// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/models/live_room_def.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/draggable_bottom_sheet.dart';
import 'package:lives/widgets/widget_group.dart';

const _coverWidth = 1280.0;
const _coverHeight = 720.0;

/// 显示[LiveRoomSheet]
Future<RoomInfo?> showLiveRoomSheet(BuildContext context) async {
  return await showGeneralDialog<RoomInfo>(
    context: context,
    barrierLabel: '',
    barrierDismissible: true,
    barrierColor: const CupertinoDynamicColor.withBrightness(
      color: Color(0x33000000),
      darkColor: Color(0x7A000000),
    ),
    pageBuilder: (context, animation, secondaryAnimation) {
      return const LiveRoomSheet();
    },
  );
}

/// Created by box on 2022/2/1.
///
/// 直播间
class LiveRoomSheet extends StatefulWidget {
  /// 直播间
  const LiveRoomSheet({Key? key}) : super(key: key);

  @override
  _LiveRoomSheetState createState() => _LiveRoomSheetState();
}

class _LiveRoomSheetState extends CompatibleState<LiveRoomSheet> {
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
      child: _RoomInfoItem(
        room: _rooms[index],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Widget sliver;
    if (_isLoading || _rooms.isEmpty) {
      sliver = SliverFillRemaining(
        child: Center(
          child: Text(
            _isLoading ? '正在加载～' : '暂无开播的主播噢～',
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 14,
            ),
          ),
        ),
      );
    } else {
      sliver = SliverList(
        delegate: SliverChildBuilderDelegate(
          _buildItem,
          childCount: _rooms.length,
        ),
      );
    }
    return DraggableBottomSheet(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(10),
      ),
      backgroundColor: CupertinoColors.white,
      navigationBar: CupertinoNavigationBar(
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
      ),
      slivers: [
        SliverSafeArea(
          sliver: sliver,
        ),
      ],
    );
  }
}

class _RoomInfoItem extends StatelessWidget {
  const _RoomInfoItem({
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
        Navigator.pop(context, room);
      },
      child: WidgetGroup.spacing(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: _coverWidth / _coverHeight,
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
                  width: _coverWidth,
                  height: _coverHeight,
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
