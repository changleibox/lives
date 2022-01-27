// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/widgets/share.dart';
import 'package:provider/provider.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';

/// Created by changlei on 2022/1/26.
///
/// 互动工具
class InteractiveTools extends StatelessWidget {
  /// 互动工具
  const InteractiveTools({
    Key? key,
    required this.model,
  }) : super(key: key);

  /// model
  final LiveModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xdd1e1d27),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          child: WidgetGroup.spacing(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            children: [
              Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: const Text(
                  '互动工具',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              WidgetGroup.spacing(
                spacing: 10,
                children: [
                  Expanded(
                    flex: 1,
                    child: _Button(
                      text: '语音连麦',
                      icon: CupertinoIcons.mic_fill,
                      onPressed: () {
                        model.requestJoinAnchor();
                      },
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _Button(
                      text: '热力风暴',
                      icon: CupertinoIcons.bitcoin_circle_fill,
                      onPressed: () {},
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
              Container(
                height: 40,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: const Text(
                  '开播设置',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                crossAxisCount: 4,
                childAspectRatio: 1.74,
                children: [
                  _Button(
                    text: '分享',
                    icon: CupertinoIcons.arrowshape_turn_up_right_fill,
                    onPressed: () {
                      showShare(context);
                    },
                  ),
                  _Button(
                    text: '背景音乐',
                    icon: CupertinoIcons.music_note_2,
                    onPressed: () {
                      final manager = model.audioEffectManager;
                      manager.setAllMusicVolume(100);
                      manager.startPlayMusic(
                        AudioMusicParam(path: BGM, id: 0),
                      );
                      manager.setMusicPitch(0, 1);
                      manager.setMusicPlayoutVolume(0, 100);
                    },
                  ),
                  _Button(
                    text: '转换镜头',
                    icon: CupertinoIcons.camera_rotate_fill,
                    onPressed: () {
                      model.switchCamera();
                    },
                  ),
                  _Button(
                    text: '闪光灯关',
                    icon: CupertinoIcons.bolt_fill,
                    onPressed: () {
                      model.enableCameraTorch();
                    },
                  ),
                  _Button(
                    text: '麦克风开',
                    icon: CupertinoIcons.mic_fill,
                    onPressed: () {
                      model.muteLocalAudio();
                    },
                  ),
                  _Button(
                    text: '贴纸',
                    icon: CupertinoIcons.smiley_fill,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '直播标题',
                    icon: CupertinoIcons.t_bubble_fill,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '分区',
                    icon: CupertinoIcons.tag_fill,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '清晰度',
                    icon: CupertinoIcons.desktopcomputer,
                    onPressed: () {
                      final manager = model.beautyManager;
                      manager.enableSharpnessEnhancement(true);
                    },
                  ),
                  _Button(
                    text: '房间管理',
                    icon: CupertinoIcons.wrench_fill,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '屏蔽用户进场',
                    icon: CupertinoIcons.wand_rays,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '主播任务',
                    icon: CupertinoIcons.checkmark_square_fill,
                    onPressed: () {},
                  ),
                  _Button(
                    text: '主播公告',
                    icon: CupertinoIcons.bag_fill,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      onPressed: () {
        Navigator.pop(context);
        onPressed?.call();
      },
      child: WidgetGroup.spacing(
        direction: Axis.vertical,
        spacing: 4,
        children: [
          Icon(
            icon,
            color: CupertinoColors.white,
          ),
          Text(
            text,
            style: const TextStyle(
              color: CupertinoColors.systemGrey,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示互动工具
Future<void> showInteractiveTools(BuildContext context) {
  final model = context.read<LiveModel>();
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return InteractiveTools(
        model: model,
      );
    },
  );
}
