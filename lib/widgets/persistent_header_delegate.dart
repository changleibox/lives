// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';

/// Created by box on 2022/1/31.
///
/// [PreferredSizeWidget]
class PreferredSizePersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// [PreferredSizeWidget]
  PreferredSizePersistentHeaderDelegate({required this.child});

  /// child
  final PreferredSizeWidget child;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

/// [Size]
class SizedPersistentHeaderDelegate extends SliverPersistentHeaderDelegate {
  /// [PreferredSizeWidget]
  SizedPersistentHeaderDelegate({
    required this.child,
    required this.minExtent,
    required this.maxExtent,
  });

  /// child
  final Widget child;

  /// minExtent
  @override
  final double minExtent;

  /// maxExtent
  @override
  final double maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return minExtent != oldDelegate.minExtent || maxExtent != oldDelegate.maxExtent;
  }
}
