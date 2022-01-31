// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:math';

import 'package:flutter/cupertino.dart';

/// 构建
typedef DynamicSafeAreaBuilder = Widget Function(BuildContext context, EdgeInsets padding);

/// Created by box on 2022/1/31.
///
/// 动态的[SafeArea]
class SliverDynamicSafeArea extends StatelessWidget {
  /// 动态的[SafeArea]
  const SliverDynamicSafeArea({
    Key? key,
    required this.builder,
    this.childHeight = 0,
  }) : super(key: key);

  /// child
  final DynamicSafeAreaBuilder builder;

  /// 子控件的高
  final double childHeight;

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
        final paddingBottom = max(0.0, padding.bottom - paintExtent + childHeight);
        final newPadding = padding.copyWith(
          top: paddingTop,
          bottom: paddingBottom,
        );
        print([paintExtent, newPadding]);
        return builder(context, newPadding);
      },
    );
  }
}
