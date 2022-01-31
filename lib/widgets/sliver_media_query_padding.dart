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

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final mediaQueryData = MediaQuery.of(context);
        final size = mediaQueryData.size;
        final padding = mediaQueryData.padding;
        final paintExtent = constraints.remainingPaintExtent;
        final extentOffset = size.height - paintExtent;
        final paddingTop = max(0.0, padding.top - extentOffset);
        return MediaQuery(
          data: mediaQueryData.copyWith(
            padding: padding.copyWith(
              left: max(left ? padding.left : 0, minimum.left),
              top: max(top ? paddingTop : 0, minimum.top),
              right: max(right ? padding.right : 0, minimum.right),
              bottom: max(bottom ? padding.bottom : 0, minimum.bottom),
            ),
          ),
          child: sliver,
        );
      },
    );
  }
}
