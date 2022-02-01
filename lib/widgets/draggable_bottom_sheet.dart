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
    this.borderRadius,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    required this.slivers,
  }) : super(key: key);

  /// [CupertinoPageScaffold.navigationBar]
  final PreferredSizeWidget? navigationBar;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  ///
  /// Applies only to boxes with rectangular shapes; ignored if [shape] is not
  /// [BoxShape.rectangle].
  ///
  /// {@macro flutter.painting.BoxDecoration.clip}
  final BorderRadius? borderRadius;

  /// The color of the widget that underlies the entire scaffold.
  ///
  /// By default uses [CupertinoTheme]'s `scaffoldBackgroundColor` when null.
  final Color? backgroundColor;

  /// Whether the [child] should size itself to avoid the window's bottom inset.
  ///
  /// For example, if there is an onscreen keyboard displayed above the
  /// scaffold, the body can be resized to avoid overlapping the keyboard, which
  /// prevents widgets inside the body from being obscured by the keyboard.
  ///
  /// Defaults to true and cannot be null.
  final bool resizeToAvoidBottomInset;

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
    final viewInsetBottom = MediaQuery.of(context).viewInsets.bottom;
    final hasViewInsets = viewInsetBottom > 0;
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: _onNotification,
        child: LayoutBuilder(
          builder: (context, constraints) {
            var dimension = constraints.biggest.height;
            if (widget.resizeToAvoidBottomInset) {
              dimension -= viewInsetBottom;
            }
            return DraggableScrollableSheet(
              maxChildSize: 1,
              minChildSize: hasViewInsets ? 1 : 0,
              initialChildSize: hasViewInsets ? 1 : 0.5,
              snap: !hasViewInsets,
              snapSizes: hasViewInsets ? null : const [0, 0.5, 1],
              builder: (context, scrollController) {
                return PrimaryScrollController(
                  controller: scrollController,
                  child: SlideTransition(
                    position: position,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: CupertinoPageScaffold(
                        backgroundColor: widget.backgroundColor,
                        resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
                        child: CustomScrollView(
                          slivers: [
                            if (navigationBar != null)
                              SliverMediaQueryPadding(
                                dimension: dimension,
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
                                dimension: dimension,
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
            );
          },
        ),
      ),
    );
  }
}
