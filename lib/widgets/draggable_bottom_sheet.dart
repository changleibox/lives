// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lives/widgets/persistent_header_delegate.dart';
import 'package:lives/widgets/sliver_media_query_padding.dart';

// Offset from offscreen below to fully on screen.
final _kBottomUpTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);
const _stoppedAnimation = AlwaysStoppedAnimation<double>(1.0);

/// Created by box on 2022/1/31.
///
/// 可拖动的[BottomSheet]
class DraggableBottomSheet extends StatelessWidget {
  /// 可拖动的[BottomSheet]
  const DraggableBottomSheet({
    Key? key,
    this.navigationBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.initialChildSize = 0.5,
    this.minChildSize = 0.25,
    this.maxChildSize = 1.0,
    this.expand = true,
    this.snap = false,
    this.snapSizes,
    this.builder,
    this.onNotification,
    required this.slivers,
  }) : super(key: key);

  /// [CupertinoPageScaffold.navigationBar]
  final PreferredSizeWidget? navigationBar;

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

  /// The initial fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// Rebuilding the sheet with a new [initialChildSize] will only move the
  /// the sheet to the new value if the sheet has not yet been dragged since it
  /// was first built or since the last call to [DraggableScrollableActuator.reset].
  ///
  /// The default value is `0.5`.
  final double initialChildSize;

  /// The minimum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `0.25`.
  final double minChildSize;

  /// The maximum fractional value of the parent container's height to use when
  /// displaying the widget.
  ///
  /// The default value is `1.0`.
  final double maxChildSize;

  /// Whether the widget should expand to fill the available space in its parent
  /// or not.
  ///
  /// In most cases, this should be true. However, in the case of a parent
  /// widget that will position this one based on its desired size (such as a
  /// [Center]), this should be set to false.
  ///
  /// The default value is true.
  final bool expand;

  /// Whether the widget should snap between [snapSizes] when the user lifts
  /// their finger during a drag.
  ///
  /// If the user's finger was still moving when they lifted it, the widget will
  /// snap to the next snap size (see [snapSizes]) in the direction of the drag.
  /// If their finger was still, the widget will snap to the nearest snap size.
  ///
  /// Rebuilding the sheet with snap newly enabled will immediately trigger a
  /// snap unless the sheet has not yet been dragged away from
  /// [initialChildSize] since first being built or since the last call to
  /// [DraggableScrollableActuator.reset].
  final bool snap;

  /// A list of target sizes that the widget should snap to.
  ///
  /// Snap sizes are fractional values of the parent container's height. They
  /// must be listed in increasing order and be between [minChildSize] and
  /// [maxChildSize].
  ///
  /// The [minChildSize] and [maxChildSize] are implicitly included in snap
  /// sizes and do not need to be specified here. For example, `snapSizes = [.5]`
  /// will result in a sheet that snaps between [minChildSize], `.5`, and
  /// [maxChildSize].
  ///
  /// Any modifications to the [snapSizes] list will not take effect until the
  /// `build` function containing this widget is run again.
  ///
  /// Rebuilding with a modified or new list will trigger a snap unless the
  /// sheet has not yet been dragged away from [initialChildSize] since first
  /// being built or since the last call to [DraggableScrollableActuator.reset].
  final List<double>? snapSizes;

  /// {@macro flutter.widgets.widgetsApp.builder}
  final TransitionBuilder? builder;

  /// Called when a notification of the appropriate type arrives at this
  /// location in the tree.
  ///
  /// Return true to cancel the notification bubbling. Return false to
  /// allow the notification to continue to be dispatched to further ancestors.
  ///
  /// The notification's [Notification.visitAncestor] method is called for each
  /// ancestor, and invokes this callback as appropriate.
  ///
  /// Notifications vary in terms of when they are dispatched. There are two
  /// main possibilities: dispatch between frames, and dispatch during layout.
  ///
  /// For notifications that dispatch during layout, such as those that inherit
  /// from [LayoutChangedNotification], it is too late to call [State.setState]
  /// in response to the notification (as layout is currently happening in a
  /// descendant, by definition, since notifications bubble up the tree). For
  /// widgets that depend on layout, consider a [LayoutBuilder] instead.
  final NotificationListenerCallback<DraggableScrollableNotification>? onNotification;

  /// slivers
  final List<Widget> slivers;

  @override
  Widget build(BuildContext context) {
    final preferredSize = navigationBar?.preferredSize;
    final navigationBarHeight = preferredSize?.height ?? 0;
    final viewInsetBottom = MediaQuery.of(context).viewInsets.bottom;
    Widget child = Container(
      color: backgroundColor,
      padding: EdgeInsets.only(
        bottom: resizeToAvoidBottomInset ? viewInsetBottom : 0,
      ),
      child: CustomScrollView(
        slivers: [
          if (navigationBar != null)
            _SliverPinnedElement(
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              height: navigationBarHeight,
              child: navigationBar!,
            ),
          ...slivers.map((e) {
            return SliverMediaQueryPadding(
              resizeToAvoidBottomInset: resizeToAvoidBottomInset,
              sliver: e,
            );
          }),
        ],
      ),
    );
    if (builder != null) {
      child = builder!(context, child);
    }
    final animation = ModalRoute.of(context)?.animation;
    final Animation<Offset> position;
    if (animation == null) {
      position = _kBottomUpTween.animate(_stoppedAnimation);
    } else {
      position = _kBottomUpTween.animate(animation);
    }
    final hasViewInsets = viewInsetBottom > 0 && resizeToAvoidBottomInset;
    return CupertinoUserInterfaceLevel(
      data: CupertinoUserInterfaceLevelData.elevated,
      child: NotificationListener<DraggableScrollableNotification>(
        onNotification: onNotification,
        child: DraggableScrollableSheet(
          maxChildSize: hasViewInsets ? 1 : maxChildSize,
          minChildSize: hasViewInsets ? 1 : minChildSize,
          initialChildSize: hasViewInsets ? 1 : initialChildSize,
          snap: !hasViewInsets && snap,
          snapSizes: hasViewInsets ? null : snapSizes,
          builder: (context, scrollController) {
            return PrimaryScrollController(
              controller: scrollController,
              child: SlideTransition(
                position: position,
                child: child,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SliverPinnedElement extends StatelessWidget {
  const _SliverPinnedElement({
    Key? key,
    required this.resizeToAvoidBottomInset,
    required this.child,
    this.height = 0,
  }) : super(key: key);

  final bool resizeToAvoidBottomInset;
  final Widget child;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SliverMediaQueryPadding(
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      sliver: Builder(
        builder: (context) {
          final mediaQueryData = MediaQuery.of(context);
          final padding = mediaQueryData.padding;
          return SliverPersistentHeader(
            pinned: true,
            delegate: SizedPersistentHeaderDelegate.extent(
              extent: height + padding.top,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
