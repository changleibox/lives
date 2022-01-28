// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:lives/frameworks/future_presenter.dart';

/// Created by changlei on 2020-02-13.
///
/// [Object]类型的的异步请求扩展类
abstract class ObjectPresenter<T extends StatefulWidget, E> extends FuturePresenter<T, E> {
  E? _object;

  /// 异步加载返回的数据
  E? get object => _object;

  @override
  bool get showProgress => false;

  @override
  bool get isEmpty => _object == null;

  @override
  bool get isNotEmpty => _object != null;

  @protected
  @override
  Future<void> onDefaultRefresh() {
    return refresh();
  }

  /// 手动刷新的时候，调用此方法
  @mustCallSuper
  Future<void> refresh() {
    return onRefresh();
  }

  @protected
  @override
  Future<E> onLoad(bool showProgress, CancelToken? cancelToken);

  @protected
  @override
  E resolve(E object) {
    return _object = object;
  }

  /// 设置默认缓存数据，会在加载完成的时候覆盖
  void setObject(E object) {
    resolve(object);
    markNeedsBuild();
  }
}
