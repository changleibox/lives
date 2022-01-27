// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';

import 'package:flatterer/flatterer.dart' as flatterer;
import 'package:flutter/cupertino.dart';
import 'package:flutter/semantics.dart';

const _radius = BorderRadius.all(Radius.circular(5.0));
const _size = 50.0;
const _boxShadow = <BoxShadow>[
  BoxShadow(
    color: Color(0x55000000),
    blurRadius: 3,
  ),
];
const _backgroundColor = CupertinoColors.tertiarySystemBackground;
const _transitionDuration = Duration(milliseconds: 335);
const _reverseTransitionDuration = Duration(milliseconds: 240);

/// Created by changlei on 2020/7/22.
///
/// 加载弹框
class Barrier {
  /// 加载弹框
  Barrier(
    BuildContext context, {
    this.child,
    this.width = _size,
    this.height = _size,
    this.boxShadow = _boxShadow,
    Color backgroundColor = _backgroundColor,
    this.borderRadius = _radius,
    Color? barrierColor,
    this.barrierDismissible = false,
    this.onWillPop,
    bool root = false,
  })  : _barrierOverlay = flatterer.AnimatedOverlay(context, rootOverlay: root),
        _contentOverlay = flatterer.AnimatedOverlay(context, rootOverlay: root),
        _modalRoute = ModalRoute.of(context),
        _completer = Completer<void>(),
        backgroundColor = CupertinoDynamicColor.resolve(backgroundColor, context),
        barrierColor = CupertinoDynamicColor.maybeResolve(barrierColor, context);

  /// 包裹内容
  factory Barrier.shrinkWrap(
    BuildContext context, {
    Widget? child,
    List<BoxShadow> boxShadow = _boxShadow,
    Color backgroundColor = _backgroundColor,
    BorderRadius borderRadius = _radius,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool root = false,
  }) {
    return Barrier(
      context,
      width: null,
      height: null,
      boxShadow: boxShadow,
      backgroundColor: backgroundColor,
      borderRadius: borderRadius,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      onWillPop: onWillPop,
      root: root,
      child: IntrinsicWidth(
        child: IntrinsicHeight(
          child: child,
        ),
      ),
    );
  }

  /// 阴影
  final List<BoxShadow> boxShadow;

  /// child
  final Widget? child;

  /// 宽
  final double? width;

  /// 高
  final double? height;

  /// 背景颜色
  final Color backgroundColor;

  /// 圆角
  final BorderRadius borderRadius;

  /// 背景
  final flatterer.AnimatedOverlay _barrierOverlay;

  /// 内容
  final flatterer.AnimatedOverlay _contentOverlay;

  /// 路由
  final ModalRoute<Object?>? _modalRoute;

  /// The color to use for the modal barrier. If this is null, the barrier will
  /// be transparent.
  final Color? barrierColor;

  /// Whether you can dismiss this route by tapping the modal barrier.
  final bool barrierDismissible;

  /// onWillPop
  final WillPopCallback? onWillPop;

  /// 监听隐藏
  final Completer<void> _completer;

  _PageRoute? _pageRoute;
  bool _isShowing = false;

  Widget _buildContent(BuildContext context, Animation<double> animation) {
    return Center(
      child: _Progress(
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: boxShadow,
          ),
          child: child ?? progress(radius: 12),
        ),
      ),
    );
  }

  /// 展示
  void show() {
    if (_isShowing) {
      return;
    }
    _isShowing = true;
    _debugAssertComplete();
    final route = _PageRoute(
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      pageBuilder: (context, animation, secondaryAnimation) {
        return _buildContent(context, animation);
      },
    );
    final transitionDuration = route.transitionDuration;
    final barrierCurve = route.barrierCurve;
    _barrierOverlay.insert(
      builder: (context, animation, secondaryAnimation) {
        return _ModalBarrier(route: route, animation: animation);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
      transitionDuration: transitionDuration,
      curve: barrierCurve,
    );
    _contentOverlay.insert(
      builder: (context, animation, secondaryAnimation) {
        return route.buildPage(context, animation, secondaryAnimation);
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return route.buildTransitions(context, animation, secondaryAnimation, child);
      },
      transitionDuration: transitionDuration,
      curve: barrierCurve,
      immediately: false,
    );
    _pageRoute = route;
    _barrierOverlay.removeListener(_onDismiss);
    _barrierOverlay.addListener(_onDismiss);
    if (_modalRoute?.isActive == true) {
      _modalRoute?.removeScopedWillPopCallback(_onWillPop);
      _modalRoute?.addScopedWillPopCallback(_onWillPop);
    }
  }

  /// 监听dismiss
  Future<void> get whenDismiss => _completer.future;

  /// 是否正在显示
  bool get isShowing => _isShowing;

  /// 隐藏
  void dismiss() {
    if (!_isShowing) {
      return;
    }
    _isShowing = false;
    _debugAssertComplete();
    final route = _pageRoute;
    if (route == null) {
      return;
    }
    final reverseTransitionDuration = route.reverseTransitionDuration;
    final barrierCurve = route.barrierCurve;
    _barrierOverlay.remove(
      transitionDuration: reverseTransitionDuration,
      curve: barrierCurve,
      immediately: false,
    );
    _contentOverlay.remove(
      transitionDuration: reverseTransitionDuration,
      curve: barrierCurve,
      immediately: false,
    );
  }

  void _onDismiss() {
    _pageRoute = null;
    _barrierOverlay.removeListener(_onDismiss);
    if (_modalRoute?.isActive == true) {
      _modalRoute?.removeScopedWillPopCallback(_onWillPop);
    }
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  Future<bool> _onWillPop() async {
    final isShowing = _isShowing;
    var doPop = onWillPop == null;
    if (isShowing && barrierDismissible && await onWillPop?.call() != false) {
      doPop = true;
      dismiss();
    }
    return !isShowing && doPop;
  }

  void _debugAssertComplete() {
    assert(!_completer.isCompleted, '该窗口已经dismissed');
  }

  /// 构建一个默认的progress
  static Widget progress({double radius = 10}) {
    return _Progress(
      child: CupertinoActivityIndicator(
        radius: radius,
      ),
    );
  }
}

/// Widget
class _Progress extends StatelessWidget {
  const _Progress({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: child,
    );
  }
}

/// Route
class _PageRoute extends PopupRoute<void> {
  _PageRoute({
    required this.pageBuilder,
    this.barrierColor,
    this.barrierDismissible = false,
  });

  final RoutePageBuilder pageBuilder;

  @override
  final Color? barrierColor;

  @override
  final bool barrierDismissible;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: pageBuilder(context, animation, secondaryAnimation),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.linearToEaseOut,
      reverseCurve: Curves.linearToEaseOut.flipped,
    );
    return ScaleTransition(
      scale: curvedAnimation,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: child,
      ),
    );
  }

  @override
  Duration get transitionDuration => _transitionDuration;

  @override
  Duration get reverseTransitionDuration => _reverseTransitionDuration;
}

class _ModalBarrier extends StatelessWidget {
  const _ModalBarrier({
    Key? key,
    required this.route,
    required this.animation,
  }) : super(key: key);

  final ModalRoute<Object?> route;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final barrierDismissible = route.barrierDismissible;
    final barrierColor = route.barrierColor;
    final barrierLabel = route.barrierLabel;
    final barrierCurve = route.barrierCurve;
    final semanticsDismissible = route.semanticsDismissible;
    Widget barrier;
    if (barrierColor != null && barrierColor.alpha != 0) {
      final color = animation.drive(
        ColorTween(
          begin: barrierColor.withOpacity(0.0),
          end: barrierColor, // changedInternalState is called if barrierColor updates
        ).chain(CurveTween(curve: barrierCurve)), // changedInternalState is called if barrierCurve updates
      );
      barrier = AnimatedModalBarrier(
        color: color,
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
      );
    } else {
      barrier = ModalBarrier(
        dismissible: barrierDismissible,
        semanticsLabel: barrierLabel,
        barrierSemanticsDismissible: semanticsDismissible,
      );
    }
    // 在消失的过程中不拦截事件
    barrier = IgnorePointer(
      ignoring: animation.status == AnimationStatus.reverse || animation.status == AnimationStatus.dismissed,
      child: barrier,
    );
    if (semanticsDismissible && barrierDismissible) {
      // To be sorted after the _modalScope.
      barrier = Semantics(
        sortKey: const OrdinalSortKey(1.0),
        child: barrier,
      );
    }
    return barrier;
  }
}
