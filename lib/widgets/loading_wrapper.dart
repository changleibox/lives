// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of future_wrapper;

/// Created by changlei on 2021/12/1.
///
/// 进度对话框
class _LoadingWrapper {
  const _LoadingWrapper._();

  /// 给future一个loading对话框
  static Future<T> wrapLoading<T>({
    required BuildContext context,
    required Future<T> Function() computation,
    required WidgetBuilder builder,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool showLoading = true,
    Duration delayed = Duration.zero,
    bool root = false,
  }) {
    if (!showLoading) {
      return computation();
    }
    final barrier = _buildBarrier(
      context: context,
      builder: builder,
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      onWillPop: onWillPop,
      root: root,
    );
    final timer = Timer(delayed, barrier.show);
    final completer = Completer<T>();
    computation().then((value) {
      completer.complete(value);
    }).catchError((Object error, StackTrace stackTrace) {
      completer.completeError(error, stackTrace);
    }).whenComplete(() {
      timer.cancel();
      barrier.dismiss();
    });
    return completer.future;
  }

  static Barrier _buildBarrier({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool root = false,
  }) {
    return Barrier(
      context,
      width: 48,
      height: 48,
      borderRadius: BorderRadius.circular(8),
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      onWillPop: onWillPop,
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color(0x20000000),
          blurRadius: 20,
          spreadRadius: 4,
        ),
      ],
      backgroundColor: CupertinoColors.systemBackground,
      root: root,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Builder(
          builder: builder,
        ),
      ),
    );
  }
}
