// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/enums/live_type.dart';
import 'package:lives/frameworks/framework.dart';
import 'package:lives/frameworks/void_presenter.dart';
import 'package:lives/models/live_error.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:lives/widgets/live_video_player.dart';
import 'package:lives/widgets/live_voice_player.dart';
import 'package:lives/widgets/watch_overlay.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

/// Created by changlei on 2022/1/25.
///
/// 观看直播
class WatchPage extends StatefulWidget with HostProvider {
  /// 构建直播页面
  const WatchPage({Key? key}) : super(key: key);

  @override
  _WatchPageState createState() => _WatchPageState();

  @override
  _WatchPresenter createPresenter() => _WatchPresenter();
}

class _WatchPageState extends HostState<WatchPage, _WatchPresenter> {
  Widget _buildPlayer() {
    final model = presenter._model;
    final key = ObjectKey(model.userId);
    switch (model.liveType) {
      case LiveType.video:
      case LiveType.game:
        return LiveVideoPlayer(
          key: key,
          onViewCreated: presenter._startWatch,
        );
      case LiveType.voice:
        return LiveVoicePlayer(
          key: key,
          alignment: model.started ? const Alignment(0.0, -0.3) : Alignment.center,
          avatar: model.getMemberInfo(model.anchorId)?.userAvatar,
          display: model.started,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => presenter._model,
      child: Consumer<WatchModel>(
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
                      child: WatchOverlay(
                        anchorId: value.anchorId,
                        userId: value.userId,
                      ),
                    ),
                  if (value.mounted && presenter._errorMessage != null)
                    Positioned.fill(
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          presenter._errorMessage!,
                          style: CupertinoTheme.of(context).textTheme.navLargeTitleTextStyle,
                        ),
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

class _WatchPresenter extends VoidPresenter<WatchPage> {
  final _model = WatchModel();

  String? _errorMessage;

  @override
  Future<void> onLoad(bool showProgress, CancelToken? cancelToken) {
    final arguments = this.arguments as Map<String, dynamic>?;
    final liveType = arguments?['liveType'] as LiveType?;
    final roomId = arguments?['roomId'] as String?;
    final anchorId = arguments?['anchorId'] as String?;
    return _model.setup(
      liveType: liveType,
      roomId: roomId,
      anchorId: anchorId,
    );
  }

  @override
  void initState() {
    _model.destroyNotifier.addListener(_onRoomDestroy);
    super.initState();
  }

  @override
  void dispose() {
    _model.destroyNotifier.removeListener(_onRoomDestroy);
    super.dispose();
  }

  @override
  void onPostFrame(Duration timeStamp) {
    super.onPostFrame(timeStamp);
    switch (_model.liveType) {
      case LiveType.video:
      case LiveType.game:
        break;
      case LiveType.voice:
        _startWatch();
        break;
    }
  }

  void _onRoomDestroy() {
    markNeedsBuild(() {
      _errorMessage = '直播已结束';
    });
  }

  Future<void> _startWatch([int? viewId]) async {
    try {
      await _model.startWatch(viewId);
    } on LiveError catch (e) {
      if (e.isNotExist) {
        _errorMessage = '直播未开始';
      } else {
        showToast(e.message.toString());
      }
    } finally {
      markNeedsBuild();
    }
  }

  Future<void> _exitWatch() async {
    try {
      await FutureWrapper.wrapLoading(
        context: context,
        computation: _model.exitWatch,
      );
    } on LiveError catch (e) {
      if (!e.isNotExist) {
        showToast(e.message);
      }
    }
  }

  Future<bool?> _onExit() async {
    if (!_model.started) {
      await _exitWatch();
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
                Navigator.pop(context, true);
                await _exitWatch();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
