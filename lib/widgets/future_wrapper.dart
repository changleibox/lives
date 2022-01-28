// Copyright (c) 2022 CHANGLEI. All rights reserved.

library future_wrapper;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lives/generated/assets.dart';
import 'package:lives/widgets/barrier.dart';
import 'package:lives/widgets/progress_indicator.dart';
import 'package:progress_indicators/progress_indicators.dart';

part 'loading_wrapper.dart';

part 'progress_wrapper.dart';

/// Created by changlei on 2020/5/28.
///
/// 给future添加一些功能，比如添加loading对话框
class FutureWrapper {
  const FutureWrapper._();

  /// 给future一个loading对话框
  static Future<T> wrapLoading<T>({
    required BuildContext context,
    required Future<T> Function() computation,
    WidgetBuilder builder = _buildLoading,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool showLoading = true,
    Duration? delayed,
    bool root = false,
  }) {
    return _LoadingWrapper.wrapLoading(
      context: context,
      computation: computation,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      onWillPop: onWillPop,
      showLoading: showLoading,
      delayed: delayed ?? Duration.zero,
      root: root,
    );
  }

  /// 显示进度对话框
  static Future<T> wrapProgress<T>({
    required BuildContext context,
    required ProgressFutureBuilder<T> computation,
    ProgressWidgetBuilder builder = _buildProgress,
    VoidCallback? onAbort,
    bool root = false,
  }) async {
    return _ProgressWrapper.wrapProgress(
      context: context,
      computation: computation,
      builder: builder,
      onAbort: onAbort,
      root: root,
    );
  }

  /// 构建loading控件
  static Widget _buildLoading(BuildContext context) {
    return GlowingProgressIndicator(
      child: Image.asset(
        Assets.images(Images.loading),
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
    );
  }

  /// 构建进度对话框
  static Widget _buildProgress(BuildContext context, ProgressEnvoy envoy, VoidCallback? onAbort) {
    return HorizontalProgressIndicator(
      message: envoy.message,
      description: envoy.description,
      count: envoy.count,
      total: envoy.total,
      onAbort: onAbort,
    );
  }
}
