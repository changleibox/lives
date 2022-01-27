// Copyright (c) 2022 CHANGLEI. All rights reserved.

part of storage;

/// Created by changlei on 3/24/21.
///
/// 本地数据持久化
class LocalStorage extends Storage {
  /// 初始化，只有一个实例
  factory LocalStorage() {
    return _instance ??= LocalStorage._();
  }

  LocalStorage._();

  static LocalStorage? _instance;

  SharedPreferences? _preferences;

  @override
  Set<String> get keys {
    return _checkNotNull(_preferences).getKeys();
  }

  @override
  Future<void> setup() async {
    if (_preferences != null) {
      return;
    }
    _preferences = await SharedPreferences.getInstance();
    notifyListeners();
  }

  @override
  Future<void> reload() async {
    await _checkNotNull(_preferences).reload();
    notifyListeners();
  }

  @override
  Future<bool> clear() async {
    return await _checkNotNull(_preferences).clear();
  }

  @override
  Future<void> dispose() async {
    _checkNotNull(_preferences);
    _preferences = null;
    super.dispose();
  }

  @override
  String? readValue(String key) {
    return Storage.encodeValue(_checkNotNull(_preferences).get(key));
  }

  @override
  Future<bool> writeValues(Map<String, String?> values) async {
    final preferences = _checkNotNull(_preferences);
    final results = await Future.wait(values.keys.map((e) {
      final value = values[e];
      if (value?.isNotEmpty == true) {
        return preferences.setString(e, value!);
      } else {
        return preferences.remove(e);
      }
    }));
    return results.every((element) => element);
  }

  SharedPreferences _checkNotNull(SharedPreferences? preferences) {
    assert(preferences != null, '未初始化，请先调用`LocalStorage.setup`');
    return preferences!;
  }
}
