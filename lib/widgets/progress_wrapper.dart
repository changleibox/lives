// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of future_wrapper;

/// 进度变更
typedef ProgressMessageCallback = void Function(
  String message,
  int? count,
  int? total, {
  String? description,
});

/// 构建进度条
typedef ProgressWidgetBuilder = Widget Function(
  BuildContext context,
  ProgressEnvoy envoy,
  VoidCallback? onAbort,
);

/// 构建进程
typedef ProgressFutureBuilder<T> = Future<T> Function(
  ProgressMessageCallback setProgress,
);

/// 进度消息体
class ProgressEnvoy {
  /// 构造函数
  const ProgressEnvoy({
    required this.message,
    required this.description,
    this.count,
    this.total,
  });

  /// 自定义的消息，显示在进度条上面
  final String message;

  /// 自定义描述，显示在进度条下面，右边，默认为0B/0B
  final String? description;

  /// 当前进度
  final int? count;

  /// 总的进度
  final int? total;
}

/// Created by changlei on 2020/10/10.
///
/// 进度对话框
class _ProgressWrapper {
  const _ProgressWrapper._();

  /// 显示进度对话框
  static Future<T> wrapProgress<T>({
    required BuildContext context,
    required ProgressFutureBuilder<T> computation,
    required ProgressWidgetBuilder builder,
    VoidCallback? onAbort,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool root = false,
  }) {
    StreamController<ProgressEnvoy>? streamController;
    Barrier? barrier;

    void setProgress(String message, int? count, int? total, {String? description}) {
      if (message.isEmpty || (count != null && total != null && count == total)) {
        return;
      }
      final sizes = <String>[
        count == null ? '--' : _convertSemanticSize(count),
        total == null ? '--' : _convertSemanticSize(total),
      ];
      if (description == null && sizes.isNotEmpty) {
        description = sizes.join('/');
      }
      final envoy = ProgressEnvoy(
        message: message,
        description: description,
        count: count,
        total: total,
      );
      streamController ??= StreamController<ProgressEnvoy>.broadcast();
      streamController!.sink.add(envoy);
      if (barrier != null && barrier!.isShowing) {
        return;
      }
      barrier = _buildBarrier(
        context,
        streamController!.stream,
        builder,
        initialData: envoy,
        onAbort: onAbort,
        barrierColor: barrierColor,
        barrierDismissible: barrierDismissible,
        onWillPop: onWillPop,
        root: root,
      );
      barrier!.show();
    }

    final completer = Completer<T>();
    computation(setProgress).then((value) {
      completer.complete(value);
    }).catchError((Object error, StackTrace stackTrace) {
      completer.completeError(error, stackTrace);
    }).whenComplete(() {
      streamController?.close();
      barrier?.dismiss();
      streamController = null;
      barrier = null;
    });
    return completer.future;
  }

  static Barrier _buildBarrier(
    BuildContext context,
    Stream<ProgressEnvoy> stream,
    ProgressWidgetBuilder builder, {
    ProgressEnvoy? initialData,
    VoidCallback? onAbort,
    Color? barrierColor,
    bool barrierDismissible = false,
    WillPopCallback? onWillPop,
    bool root = false,
  }) {
    return Barrier.shrinkWrap(
      context,
      boxShadow: const <BoxShadow>[
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.1),
          spreadRadius: 4,
          blurRadius: 20,
          offset: Offset(0, 0),
        ),
      ],
      borderRadius: BorderRadius.circular(10),
      barrierColor: barrierColor,
      barrierDismissible: barrierDismissible,
      onWillPop: onWillPop,
      root: root,
      child: Material(
        type: MaterialType.transparency,
        child: StreamBuilder<ProgressEnvoy>(
          initialData: initialData,
          stream: stream,
          builder: (context, snapshot) {
            return builder(context, snapshot.data!, onAbort);
          },
        ),
      ),
    );
  }

  /// 转换为可读的大小
  static String _convertSemanticSize(int? size) {
    if (size == null || size == 0) {
      return '0B';
    }

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    const tb = gb * 1024;

    if (size >= tb) {
      return '${(size / tb).toStringAsFixed(2)}TB';
    }
    if (size >= gb) {
      return '${(size / gb).toStringAsFixed(2)}GB';
    }
    if (size >= mb) {
      return '${(size / mb).toStringAsFixed(2)}MB';
    }
    if (size >= kb) {
      return '${(size / kb).toStringAsFixed(2)}KB';
    }
    return '${size}B';
  }
}
