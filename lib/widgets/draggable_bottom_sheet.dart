// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/physics.dart';
import 'package:lives/widgets/persistent_header_delegate.dart';
import 'package:lives/widgets/sliver_media_query_padding.dart';

// Offset from offscreen below to fully on screen.
final _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

/// Created by box on 2022/1/31.
///
/// 可拖动的[BottomSheet]
class DraggableBottomSheet extends StatefulWidget {
  /// 可拖动的[BottomSheet]
  const DraggableBottomSheet({
    Key? key,
    this.navigationBar,
    this.backgroundColor,
    this.borderRadius,
    required this.slivers,
  }) : super(key: key);

  /// [CupertinoPageScaffold.navigationBar]
  final PreferredSizeWidget? navigationBar;

  /// The color of the widget that underlies the entire scaffold.
  ///
  /// By default uses [CupertinoTheme]'s `scaffoldBackgroundColor` when null.
  final Color? backgroundColor;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  ///
  /// {@macro flutter.painting.BoxDecoration.clip}
  final BorderRadius? borderRadius;

  /// slivers
  final List<Widget> slivers;

  @override
  _DraggableBottomSheetState createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  static final _epsilon = Tolerance.defaultTolerance.distance;

  bool _popped = false;

  bool _onNotification(DraggableScrollableNotification notification) {
    final extent = notification.extent;
    if (!_popped && nearZero(extent, _epsilon)) {
      Navigator.pop(context);
      _popped = true;
    }
    return !_popped;
  }

  @override
  Widget build(BuildContext context) {
    final animation = ModalRoute.of(context)?.animation;
    final Animation<Offset> position;
    if (animation == null) {
      position = _kBottomUpTween.animate(const AlwaysStoppedAnimation(1));
    } else {
      position = _kBottomUpTween.animate(animation);
    }
    final navigationBar = widget.navigationBar;
    final preferredSize = navigationBar?.preferredSize;
    final navigationBarHeight = preferredSize?.height ?? 0;
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: _onNotification,
        child: DraggableScrollableSheet(
          expand: true,
          initialChildSize: 0.5,
          maxChildSize: 1,
          minChildSize: 0,
          snap: true,
          snapSizes: const [0, 0.5, 1],
          builder: (context, scrollController) {
            return SlideTransition(
              position: position,
              child: ClipRRect(
                borderRadius: widget.borderRadius ?? BorderRadius.zero,
                clipBehavior: Clip.antiAlias,
                child: CupertinoPageScaffold(
                  backgroundColor: widget.backgroundColor,
                  child: PrimaryScrollController(
                    controller: scrollController,
                    child: CustomScrollView(
                      slivers: [
                        if (navigationBar != null)
                          SliverMediaQueryPadding(
                            sliver: Builder(
                              builder: (context) {
                                final mediaQueryData = MediaQuery.of(context);
                                final padding = mediaQueryData.padding;
                                return SliverPersistentHeader(
                                  pinned: true,
                                  delegate: SizedPersistentHeaderDelegate.extent(
                                    extent: navigationBarHeight + padding.top,
                                    child: navigationBar,
                                  ),
                                );
                              },
                            ),
                          ),
                        ...widget.slivers.map((e) {
                          return SliverMediaQueryPadding(
                            top: navigationBar == null,
                            sliver: e,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
