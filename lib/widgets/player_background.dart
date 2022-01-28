// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/commons/test_data.dart';

/// Created by changlei on 2022/1/28.
///
/// 播放器背景
class PlayerBackground extends StatelessWidget {
  /// 播放器背景
  const PlayerBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// child
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: background,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 8,
                sigmaY: 8,
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
