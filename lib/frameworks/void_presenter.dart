// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:lives/frameworks/object_presenter.dart';

/// Created by changlei on 2020-02-13.
///
/// [void]类型的的异步请求扩展类
abstract class VoidPresenter<T extends StatefulWidget> extends ObjectPresenter<T, void> {
  @override
  bool get isEmpty => true;

  @override
  bool get isNotEmpty => false;
}
