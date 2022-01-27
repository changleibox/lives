// Copyright (c) 2022 CHANGLEI. All rights reserved.

const _groupNotExist = 10010;
const _invalidGroupId = 10015;

/// Created by changlei on 2022/1/21.
///
/// 直播错误
class LiveError extends Error {
  /// 直播错误
  LiveError(this.code, this.message);

  /// 错误码
  final int code;

  /// 错误信息
  final String message;

  /// 是否为不存在
  bool get isNotExist => code == _groupNotExist || code == _invalidGroupId || message == 'not enter room yet';

  @override
  String toString() {
    return 'LiveError{code: $code, message: ${Error.safeToString(message)}';
  }
}
