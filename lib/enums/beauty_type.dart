// Copyright (c) 2022 CHANGLEI. All rights reserved.

/// Created by changlei on 2022/1/27.
///
/// 美颜类型
enum BeautyType {
  /// 光滑
  smooth,

  /// 自然
  nature,

  /// P图
  pitu,

  /// 美白
  whitening,

  /// 红润
  ruddy,
}

/// 美颜类型名称
extension BeautyTypeName on BeautyType {
  /// 名称
  String get label {
    switch (this) {
      case BeautyType.smooth:
        return '光滑';
      case BeautyType.nature:
        return '自然';
      case BeautyType.pitu:
        return 'P图';
      case BeautyType.whitening:
        return '美白';
      case BeautyType.ruddy:
        return '红润';
    }
  }
}
