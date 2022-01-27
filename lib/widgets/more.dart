// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2022/1/26.
///
/// 更多弹窗
class More extends StatelessWidget {
  /// 更多弹窗
  const More({Key? key}) : super(key: key);

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
          child: WidgetGroup(
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            divider: Container(
              height: 0,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: CupertinoColors.opaqueSeparator,
                    width: 0,
                  ),
                ),
              ),
            ),
            children: [
              Container(
                height: 40,
                alignment: Alignment.center,
                child: const Text(
                  '更多',
                  style: TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.white,
                  ),
                ),
              ),
              Container(
                child: WidgetGroup.spacing(
                  spacing: 10,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      onPressed: () {},
                      child: WidgetGroup.spacing(
                        direction: Axis.vertical,
                        spacing: 4,
                        children: const [
                          Icon(
                            CupertinoIcons.paw,
                            color: CupertinoColors.white,
                          ),
                          Text(
                            '竖屏',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      onPressed: () {},
                      child: WidgetGroup.spacing(
                        direction: Axis.vertical,
                        spacing: 4,
                        children: const [
                          Icon(
                            CupertinoIcons.paw,
                            color: CupertinoColors.white,
                          ),
                          Text(
                            '清晰度',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      onPressed: () {},
                      child: WidgetGroup.spacing(
                        direction: Axis.vertical,
                        spacing: 4,
                        children: const [
                          Icon(
                            CupertinoIcons.paw,
                            color: CupertinoColors.white,
                          ),
                          Text(
                            '房间管理',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      onPressed: () {},
                      child: WidgetGroup.spacing(
                        direction: Axis.vertical,
                        spacing: 4,
                        children: const [
                          Icon(
                            CupertinoIcons.paw,
                            color: CupertinoColors.white,
                          ),
                          Text(
                            '主播公告',
                            style: TextStyle(
                              color: CupertinoColors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示更多弹窗
Future<void> showMore(BuildContext context) {
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return const More();
    },
  );
}
