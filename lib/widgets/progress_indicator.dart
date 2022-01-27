// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_grasp/flutter_grasp.dart';

const _progressHeight = 12.0;

/// Created by changlei on 2021/12/1.
///
/// 进度指示器
class HorizontalProgressIndicator extends StatelessWidget {
  /// 构建进度指示器
  const HorizontalProgressIndicator({
    Key? key,
    required this.message,
    required this.count,
    required this.total,
    this.description,
    this.onAbort,
  }) : super(key: key);

  /// 显示在进度上面的信息
  final String message;

  /// 当前进度
  final int? count;

  /// 总进度
  final int? total;

  /// 进度描述
  final String? description;

  /// 点击终端按钮
  final VoidCallback? onAbort;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 400,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: WidgetGroup.spacing(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            direction: Axis.vertical,
            spacing: 15,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(_progressHeight / 2),
                child: LinearProgressIndicator(
                  value: count == null || total == null ? null : (count! / (total! == 0 ? 1 : total!)),
                  minHeight: _progressHeight,
                  backgroundColor: const Color(0xfff0f0f0),
                ),
              ),
              if (description?.isNotEmpty == true)
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    description!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.secondaryLabel,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (onAbort != null)
          Positioned(
            top: 0,
            right: 0,
            child: CupertinoButton(
              onPressed: onAbort,
              minSize: 40,
              padding: EdgeInsets.zero,
              child: const Text('终止'),
            ),
          ),
      ],
    );
  }
}
