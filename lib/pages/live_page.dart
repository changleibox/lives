// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/models/live_error.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/live_capture_player.dart';
import 'package:lives/widgets/live_overlay.dart';
import 'package:lives/widgets/live_video_player.dart';
import 'package:lives/widgets/live_voice_player.dart';
import 'package:lives/widgets/not_live_overlay.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

/// Created by changlei on 2022/1/18.
///
/// 直播
class LivePage extends StatefulWidget with HostProvider {
  /// 构建直播页面
  const LivePage({Key? key}) : super(key: key);

  @override
  _LivePageState createState() => _LivePageState();

  @override
  _LivePresenter createPresenter() => _LivePresenter();
}

class _LivePageState extends HostState<LivePage, _LivePresenter> {
  Widget _buildPlayer() {
    final model = presenter._model;
    final key = ObjectKey(model.userId);
    switch (model.liveType) {
      case LiveType.video:
        return LiveVideoPlayer(
          key: key,
          onViewCreated: presenter._startPreview,
        );
      case LiveType.game:
        return LiveCapturePlayer(
          key: key,
          alignment: model.started ? const Alignment(0.0, -0.3) : Alignment.center,
          started: model.started,
        );
      case LiveType.voice:
        return LiveVoicePlayer(
          key: key,
          alignment: model.started ? const Alignment(0.0, -0.3) : Alignment.center,
          avatar: model.getMemberInfo(model.userId)?.userAvatar,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => presenter._model,
      child: Consumer<LiveModel>(
        builder: (context, value, child) {
          return WillPopScope(
            onWillPop: () async {
              final result = await presenter._onExit();
              return result == true;
            },
            child: CupertinoPageScaffold(
              backgroundColor: CupertinoColors.white,
              resizeToAvoidBottomInset: false,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (value.mounted)
                    Positioned.fill(
                      child: _buildPlayer(),
                    ),
                  if (value.mounted)
                    Positioned.fill(
                      child: Builder(
                        builder: (context) {
                          Widget child;
                          if (value.started) {
                            child = LiveOverlay(
                              userId: value.userId,
                            );
                          } else {
                            child = NotLiveOverlay(
                              userId: value.userId,
                              onStart: presenter._startLive,
                            );
                          }
                          return AnimatedSwitcher(
                            duration: const Duration(
                              milliseconds: 300,
                            ),
                            child: child,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LivePresenter extends VoidPresenter<LivePage> {
  final _model = LiveModel();

  @override
  Future<void> onLoad(bool showProgress, CancelToken? cancelToken) {
    return _model.setup();
  }

  Future<void> _startPreview(int viewId) async {
    try {
      await _model.startPreview(true, viewId);
    } on LiveError catch (e) {
      showToast(e.message.toString());
    }
  }

  Future<void> _stopPreview() async {
    try {
      await _model.stopPreview();
    } on LiveError catch (e) {
      showToast(e.message.toString());
    }
  }

  Future<void> _startLive() async {
    try {
      await FutureWrapper.wrapLoading(
        context: context,
        computation: _model.startLive,
      );
      await _model.liveType.start();
    } on LiveError catch (e) {
      showToast(e.message.toString());
    }
  }

  Future<void> _exitLive() async {
    try {
      await FutureWrapper.wrapLoading(
        context: context,
        computation: _model.exitLive,
      );
    } on LiveError catch (e) {
      showToast(e.message);
    }
  }

  Future<bool?> _onExit() async {
    if (!_model.started) {
      await _stopPreview();
      return true;
    }
    return await showCupertinoDialog<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
          content: const Text('您确定要退出当前直播吗？'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () async {
                Navigator.pop(context, false);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                await _exitLive();
                Navigator.pop(context, false);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
