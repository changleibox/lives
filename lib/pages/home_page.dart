// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/live_room_sheet.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

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
    final room = await showLiveRoomSheet(context);
    if (room == null) {
      return;
    }
    final roomId = room.roomId;
    final anchorId = room.ownerId;
    final liveType = room.liveType;
    await Routes.watch.pushNamed(
      context,
      arguments: <String, dynamic>{
        'roomId': roomId,
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
