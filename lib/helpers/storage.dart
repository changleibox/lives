// Copyright (c) 2022 CHANGLEI. All rights reserved.

library storage;

import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:lives/utils/nums.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'package:lives/helpers/local_storage.dart';

/// 获取默认值
typedef ObjectValueGetter = Object? Function(String key);

/// Created by changlei on 2020/7/27.
///
/// 数据持久化
abstract class Storage extends ChangeNotifier with MapMixin<String, Object?>, StorageReaderMixin, StorageWriterMixin {
  /// 编码value为String类型
  static String? encodeValue(Object? value) {
    if (value == null) {
      return null;
    }
    String? encodedValue;
    if (value is num || value is bool || value is String) {
      encodedValue = value.toString();
    } else if (value is Iterable) {
      encodedValue = json.encode(value.toList());
    } else if (value is Map) {
      encodedValue = json.encode(value);
    } else {
      encodedValue = json.encode(value);
    }
    return encodedValue;
  }
}

/// 读取
abstract class StorageReader extends ChangeNotifier with StorageReaderMixin {}

/// 写入
abstract class StorageWriter extends ChangeNotifier with StorageWriterMixin {}

/// 数据持久化-读取
mixin StorageReaderMixin on Object {
  /// 获取所有key
  Set<String> get keys;

  /// 加载
  Future<void> setup();

  /// 重新加载
  Future<void> reload();

  /// 等同于[get]
  Object? operator [](Object? key) {
    if (key == null) {
      return null;
    }
    return get<Object?>(key.toString());
  }

  /// 获取
  T? get<T>(String key, {T? defaultValue}) {
    final encodedValue = readValue(key);
    if (encodedValue?.isNotEmpty != true) {
      return defaultValue;
    }
    if (T == int) {
      return parseInt(encodedValue, defaultValue: defaultValue as int?) as T?;
    }
    if (T == double) {
      return parseDouble(encodedValue, defaultValue: defaultValue as double?) as T?;
    }
    if (T == num) {
      return parseNum(encodedValue, defaultValue: defaultValue as num?) as T?;
    }
    if (T == bool) {
      return (encodedValue!.toLowerCase() == true.toString()) as T? ?? defaultValue;
    }
    if (T == String || T == dynamic) {
      return (encodedValue as T?) ?? defaultValue;
    }
    try {
      return (json.decode(encodedValue!) as T?) ?? defaultValue;
    } catch (e) {
      return (encodedValue as T?) ?? defaultValue;
    }
  }

  /// 批量获取
  Map<String, Object?> gets(Iterable<String> keys, {ObjectValueGetter? defaultValue}) {
    return Map<String, Object?>.fromEntries(keys.map((e) {
      return MapEntry<String, Object?>(e, get<Object?>(e, defaultValue: defaultValue?.call(e)));
    }));
  }

  /// 获取一个value
  @protected
  String? readValue(String key);
}

/// 数据持久化-写入
mixin StorageWriterMixin on ChangeNotifier {
  /// 删除
  Future<bool> remove(Object? key) async {
    if (key == null) {
      return false;
    }
    return set(key.toString(), null);
  }

  /// 批量删除
  Future<bool> removes(Iterable<String> keys) {
    return sets(Map.fromEntries(keys.map(_toNullMapEntry)));
  }

  /// 清空
  Future<bool> clear();

  /// 等同于[set]
  void operator []=(String key, Object? value) {
    set(key, value);
  }

  /// 保存
  Future<bool> set(String key, Object? value) {
    return sets(<String, Object?>{key: value});
  }

  /// 批量保存
  Future<bool> sets(Map<String, Object?> values) async {
    final encodedValues = <String, String?>{};
    for (var key in values.keys) {
      final encodedValue = Storage.encodeValue(values[key]);
      if (readValue(key) != encodedValue) {
        encodedValues[key] = encodedValue;
      }
    }
    if (encodedValues.isEmpty) {
      return false;
    }
    try {
      return await writeValues(encodedValues);
    } finally {
      notifyListeners();
    }
  }

  /// 获取一个value
  @protected
  String? readValue(String key);

  /// 批量保存
  @protected
  Future<bool> writeValues(Map<String, String?> values);
}

/// 转换成value为null的[MapEntry]
MapEntry<String, Object?> _toNullMapEntry(String key) => MapEntry(key, null);
