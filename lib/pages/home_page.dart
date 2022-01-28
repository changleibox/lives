// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/widget_group.dart';
import 'package:oktoast/oktoast.dart';
import 'package:permission_handler/permission_handler.dart';

const _keyboardDuration = Duration(milliseconds: 250);

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
    await Routes.live.pushNamed(context);
  }

  Future<void> _startWatch() async {
    if (!await _checkPermission()) {
      return;
    }
    final result = await showCupertinoDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return const _AnchorIdTextField();
      },
    );
    if (result == null) {
      return;
    }
    final anchorId = result['anchorId'] as String?;
    final liveType = result['liveType'] as LiveType?;
    await Future<void>.delayed(_keyboardDuration);
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

class _AnchorIdTextFieldState extends State<_AnchorIdTextField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onConfirm({
    required String text,
    LiveType liveType = LiveType.video,
  }) async {
    if (text.isEmpty) {
      showToast('请输入主播ID');
      return;
    }
    Navigator.pop(context, {
      'anchorId': text,
      'liveType': liveType,
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoAlertDialog(
      insetAnimationDuration: _keyboardDuration,
      title: const Text('主播ID'),
      content: SizedBox(
        height: 32,
        child: CupertinoTextField(
          controller: _controller,
          placeholder: '请输入主播ID',
          autofocus: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            fontSize: 14,
          ),
          placeholderStyle: const TextStyle(
            fontSize: 14,
            color: CupertinoColors.placeholderText,
          ),
          onSubmitted: (value) {
            _onConfirm(text: value);
          },
        ),
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () {
            _onConfirm(
              text: _controller.text,
              liveType: LiveType.video,
            );
          },
          child: const Text('视频'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            _onConfirm(
              text: _controller.text,
              liveType: LiveType.game,
            );
          },
          child: const Text('游戏'),
        ),
        CupertinoDialogAction(
          onPressed: () {
            _onConfirm(
              text: _controller.text,
              liveType: LiveType.voice,
            );
          },
          child: const Text('语音'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          child: const Text('取消'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
