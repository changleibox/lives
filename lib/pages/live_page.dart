// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/frameworks/void_presenter.dart';
import 'package:lives/models/live_error.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/live_capture_player.dart';
import 'package:lives/widgets/live_overlay.dart';
import 'package:lives/widgets/live_video_player.dart';
import 'package:lives/widgets/live_voice_player.dart';
import 'package:lives/widgets/not_live_overlay.dart';
import 'package:lives/widgets/player_background.dart';
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
    final Widget child;
    switch (model.liveType) {
      case LiveType.video:
        child = LiveVideoPlayer(
          key: key,
          onViewCreated: presenter._startPreview,
        );
        break;
      case LiveType.game:
        child = LiveCapturePlayer(
          key: key,
          started: model.started,
        );
        break;
      case LiveType.voice:
        child = LiveVoicePlayer(
          key: key,
          alignment: model.started ? const Alignment(0.0, -0.3) : Alignment.center,
          avatar: model.getMemberInfo(model.userId)?.userAvatar,
        );
        break;
    }
    return PlayerBackground(
      child: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 300,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => presenter._model,
      child: Consumer<LiveModel>(
        builder: (context, value, child) {
          return WillPopScope(
            onWillPop: () async {
              return (await presenter._onExit()) == true;
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
  void initState() {
    _model.liveType.setup();
    _model.startedNotifier.addListener(_onLiveStartedListener);
    super.initState();
  }

  @override
  void dispose() {
    _model.liveType.dispose();
    _model.startedNotifier.removeListener(_onLiveStartedListener);
    super.dispose();
  }

  @override
  Future<void> onLoad(bool showProgress, CancelToken? cancelToken) {
    final arguments = this.arguments as Map<String, dynamic>?;
    final liveType = arguments?['liveType'] as LiveType?;
    return _model.setup(liveType: liveType);
  }

  void _onLiveStartedListener() {
    if (!_model.started) {
      Routes.liveStopped.pushNamed(context);
    }
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
    return await showCupertinoDialog<bool?>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: const Text('提示'),
          content: const Text('您确定要退出当前直播吗？'),
          actions: [
            CupertinoDialogAction(
              child: const Text('取消'),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () async {
                Navigator.pop(context);
                await _exitLive();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
