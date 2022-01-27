// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter_grasp/flutter_grasp.dart';

/// Created by changlei on 2022/1/18.
///
/// num相关工具类

/// 解析成double
double? parseDouble(Object? source, {double? defaultValue = 0}) {
  if (source is double) {
    return source;
  }
  if (TextUtils.isEmpty(source?.toString())) {
    return defaultValue;
  }
  return double.tryParse(source!.toString()) ?? defaultValue;
}

/// 解析成int
int? parseInt(Object? source, {int? defaultValue = 0}) {
  if (source is int) {
    return source;
  }
  if (TextUtils.isEmpty(source?.toString())) {
    return defaultValue;
  }
  return int.tryParse(source!.toString()) ?? defaultValue;
}

/// 解析成num
num? parseNum(Object? source, {num? defaultValue = 0}) {
  if (source is num) {
    return source;
  }
  if (TextUtils.isEmpty(source?.toString())) {
    return defaultValue;
  }
  return num.tryParse(source!.toString()) ?? defaultValue;
}

/// 加
T sum<T extends num>(T? a, T? b) {
  if (a == null) {
    return b ?? (T == double ? 0.0 : 0) as T;
  } else if (b == null) {
    return a;
  }
  return a + b as T;
}

/// 是否为0或者null
bool isZeroOrNull(num? value) {
  return value == null || value == 0;
}
