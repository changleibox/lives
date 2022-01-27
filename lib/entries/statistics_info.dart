// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/foundation.dart';

/// Created by changlei on 2022/1/25.
///
/// 统计的信息
class StatisticsInfo extends Object {
  /// 统计的信息
  const StatisticsInfo({
    required this.appCpu,
    required this.rtt,
    required this.receivedBytes,
    required this.systemCpu,
    required this.remoteArray,
    required this.sendBytes,
    required this.downLoss,
    required this.localArray,
    required this.upLoss,
  });

  /// 从json构建
  factory StatisticsInfo.fromJson(Map<String, dynamic> srcJson) {
    return StatisticsInfo(
      appCpu: srcJson['appCpu'] as int,
      rtt: srcJson['rtt'] as int,
      receivedBytes: srcJson['receivedBytes'] as int,
      systemCpu: srcJson['systemCpu'] as int,
      remoteArray: (srcJson['remoteArray'] as List<dynamic>).cast<Arrays>(),
      sendBytes: srcJson['sendBytes'] as int,
      downLoss: srcJson['downLoss'] as int,
      localArray: (srcJson['localArray'] as List<dynamic>).cast<Arrays>(),
      upLoss: srcJson['upLoss'] as int,
    );
  }

  /// [appCpu]
  final int appCpu;

  /// [rtt]
  final int rtt;

  /// [receivedBytes]
  final int receivedBytes;

  /// [systemCpu]
  final int systemCpu;

  /// [remoteArray]
  final List<Arrays> remoteArray;

  /// [sendBytes]
  final int sendBytes;

  /// [downLoss]
  final int downLoss;

  /// [localArray]
  final List<Arrays> localArray;

  /// [upLoss]
  final int upLoss;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StatisticsInfo &&
          runtimeType == other.runtimeType &&
          appCpu == other.appCpu &&
          rtt == other.rtt &&
          receivedBytes == other.receivedBytes &&
          systemCpu == other.systemCpu &&
          listEquals(remoteArray, other.remoteArray) &&
          sendBytes == other.sendBytes &&
          downLoss == other.downLoss &&
          listEquals(localArray, other.localArray) &&
          upLoss == other.upLoss;

  @override
  int get hashCode =>
      appCpu.hashCode ^
      rtt.hashCode ^
      receivedBytes.hashCode ^
      systemCpu.hashCode ^
      Object.hashAll(remoteArray) ^
      sendBytes.hashCode ^
      downLoss.hashCode ^
      Object.hashAll(localArray) ^
      upLoss.hashCode;
}

/// [Arrays]
class Arrays extends Object {
  /// [Arrays]
  const Arrays({
    required this.width,
    required this.height,
    required this.audioBitrate,
    required this.streamType,
    required this.videoBitrate,
    required this.audioSampleRate,
    required this.frameRate,
  });

  /// 从json构建
  factory Arrays.fromJson(Map<String, dynamic> srcJson) {
    return Arrays(
      width: srcJson['width'] as int,
      height: srcJson['height'] as int,
      audioBitrate: srcJson['audioBitrate'] as int,
      streamType: srcJson['streamType'] as int,
      videoBitrate: srcJson['videoBitrate'] as int,
      audioSampleRate: srcJson['audioSampleRate'] as int,
      frameRate: srcJson['frameRate'] as int,
    );
  }

  /// [width]
  final int width;

  /// [height]
  final int height;

  /// [audioBitrate]
  final int audioBitrate;

  /// [streamType]
  final int streamType;

  /// [videoBitrate]
  final int videoBitrate;

  /// [audioSampleRate]
  final int audioSampleRate;

  /// [frameRate]
  final int frameRate;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Arrays &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          audioBitrate == other.audioBitrate &&
          streamType == other.streamType &&
          videoBitrate == other.videoBitrate &&
          audioSampleRate == other.audioSampleRate &&
          frameRate == other.frameRate;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      audioBitrate.hashCode ^
      streamType.hashCode ^
      videoBitrate.hashCode ^
      audioSampleRate.hashCode ^
      frameRate.hashCode;
}
