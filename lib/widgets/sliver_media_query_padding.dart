// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:math';

import 'package:flutter/cupertino.dart';

/// Created by box on 2022/1/31.
///
/// 动态的[SafeArea]
class SliverMediaQueryPadding extends StatelessWidget {
  /// 动态的[SafeArea]
  const SliverMediaQueryPadding({
    Key? key,
    required this.sliver,
    this.left = true,
    this.top = true,
    this.right = true,
    this.bottom = true,
    this.minimum = EdgeInsets.zero,
    this.resizeToAvoidBottomInset = true,
  }) : super(key: key);

  /// child
  final Widget sliver;

  /// Whether to avoid system intrusions on the left.
  final bool left;

  /// Whether to avoid system intrusions at the top of the screen, typically the
  /// system status bar.
  final bool top;

  /// Whether to avoid system intrusions on the right.
  final bool right;

  /// Whether to avoid system intrusions on the bottom side of the screen.
  final bool bottom;

  /// This minimum padding to apply.
  ///
  /// The greater of the minimum insets and the media padding will be applied.
  final EdgeInsets minimum;

  /// Whether the [child] should size itself to avoid the window's bottom inset.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true and cannot be null.
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final mediaQueryData = MediaQuery.of(context);
    final height = mediaQueryData.size.height;
    final padding = mediaQueryData.padding;
    final paddingTop = padding.top;
    final viewInsetBottom = mediaQueryData.viewInsets.bottom;
    final dimension = height - (resizeToAvoidBottomInset ? viewInsetBottom : 0);
    final newPadding = padding.copyWith(
      left: max(left ? padding.left : 0, minimum.left),
      top: max(top ? paddingTop : 0, minimum.top),
      right: max(right ? padding.right : 0, minimum.right),
      bottom: max(bottom ? padding.bottom : 0, minimum.bottom),
    );
    if (!top) {
      return MediaQuery(
        data: mediaQueryData.copyWith(
          padding: newPadding,
        ),
        child: sliver,
      );
    }
    final viewportMainAxisExtent = paddingTop - dimension;
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final remainingPaintExtent = constraints.remainingPaintExtent;
        final precedingScrollExtent = constraints.precedingScrollExtent;
        final newPaddingTop = viewportMainAxisExtent + remainingPaintExtent - precedingScrollExtent;
        return MediaQuery(
          data: mediaQueryData.copyWith(
            padding: newPadding.copyWith(
              top: max(newPaddingTop.clamp(0.0, paddingTop), minimum.top),
            ),
          ),
          child: sliver,
        );
      },
    );
  }
}
