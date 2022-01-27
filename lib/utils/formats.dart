// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';
import 'package:intl/number_symbols_data.dart';

/// 格式化时间、金额、百分比
class Formats {
  const Formats._();

  static const Locale _locale = Locale('zh', 'CN');
  static const _datePattern = 'yyyy-MM-dd';
  static const _dateTimePattern = 'yyyy-MM-dd HH:mm:ss';

  /// numberFormatSymbols[locale]
  static NumberSymbols get symbols => numberFormatSymbols[_locale.toString()] as NumberSymbols;

  /// 获取当前中文金额符号
  static String currencySymbol() {
    return NumberFormat.simpleCurrency(locale: _locale.toString()).simpleCurrencySymbol(symbols.DEF_CURRENCY_CODE);
  }

  /// 格式化百分比
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static String? formatPercent(
    num? number, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (number == null) {
      return null;
    }
    if (number == -0) {
      number = number.abs();
    }
    return percentFormat(
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    ).format(number);
  }

  /// 格式化数字
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static String? formatNumber(
    num? number, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (number == null) {
      return null;
    }
    if (number == -0) {
      number = number.abs();
    }
    return numberFormat(
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    ).format(number);
  }

  /// 格式化金额，有金额符号
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static String? formatCurrency(
    num? number, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (number == null) {
      return null;
    }
    if (number == -0) {
      number = number.abs();
    }
    return currencyFormat(
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    ).format(number);
  }

  /// 格式化数字
  /// A number format for "long" compact representations, e.g. "1.2 million"
  /// instead of of "1,200,000".
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static String? formatCompactNumber(
    num? number, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (number == null) {
      return null;
    }
    if (number == -0) {
      number = number.abs();
    }
    return compactNumberFormat(
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    ).format(number);
  }

  /// 格式化金额，有金额符号
  /// A number format for "long" compact representations, e.g. "1.2 million"
  /// instead of of "1,200,000".
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static String? formatCompactCurrency(
    num? number, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (number == null) {
      return null;
    }
    if (number == -0) {
      number = number.abs();
    }
    return compactCurrencyFormat(
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    ).format(number);
  }

  /// 格式化百分比
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat percentFormat({
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    return assembleFormat(
      NumberFormat.percentPattern(),
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    );
  }

  /// 格式化数字
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat numberFormat({
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    return assembleFormat(
      NumberFormat.decimalPattern(),
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    );
  }

  /// 格式化金额，有金额符号
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat currencyFormat({
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    return assembleFormat(
      NumberFormat.simpleCurrency(),
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    );
  }

  /// 格式化数字
  /// A number format for "long" compact representations, e.g. "1.2 million"
  /// instead of of "1,200,000".
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat compactNumberFormat({
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    return assembleFormat(
      NumberFormat.compactLong(),
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    );
  }

  /// 格式化金额，有金额符号
  /// A number format for "long" compact representations, e.g. "1.2 million"
  /// instead of of "1,200,000".
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat compactCurrencyFormat({
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    return assembleFormat(
      NumberFormat.compactSimpleCurrency(),
      decimalDigits: decimalDigits,
      segmented: segmented,
      fixedDecimalDigits: fixedDecimalDigits,
    );
  }

  /// 组装一个有效的[NumberFormat]
  ///
  /// [decimalDigits]-小数位数
  /// [segmented]-是否用逗号分隔
  static NumberFormat assembleFormat(
    NumberFormat format, {
    int? decimalDigits,
    bool segmented = true,
    bool fixedDecimalDigits = false,
  }) {
    if (fixedDecimalDigits) {
      format.minimumFractionDigits = decimalDigits ?? 10;
    } else {
      format.minimumFractionDigits = 0;
    }
    format.maximumFractionDigits = decimalDigits ?? 10;
    if (!segmented) {
      format.turnOffGrouping();
    }
    return format;
  }

  /// 格式化成万
  static String? formatTenThousand(
    num? number, {
    NumberFormat? format,
    bool compact = true,
  }) {
    if (number == null) {
      return null;
    }
    var suffix = '';
    if (number == -0) {
      number = number.abs();
    }
    if (compact && number.abs() > 9999.99) {
      number /= 10000;
      suffix = '万';
    }
    format ??= numberFormat(
      decimalDigits: 2,
      fixedDecimalDigits: false,
    );
    return '${format.format(number)}$suffix';
  }

  /// 格式化时间戳为yyyy-MM-dd格式的时间，[separator]默认为'-'
  static String? formatDateTimeRange(
    DateTime? start,
    DateTime? end, {
    String? newPattern,
    String? locale,
    String separator = '-',
  }) {
    if (start == null && end == null) {
      return null;
    }
    final dateFormat = DateFormat(newPattern ?? _datePattern, locale);
    final formattedDateTimes = <String>{
      if (start != null) dateFormat.format(start),
      if (end != null) dateFormat.format(end),
    };
    return formattedDateTimes.join(separator);
  }

  /// 格式化时间戳为yyyy-MM-dd格式的时间
  static String? formatDate(DateTime? dateTime, {String? locale}) {
    return formatDateTime(dateTime, newPattern: _datePattern, locale: locale);
  }

  /// 格式化时间戳为yyyy-MM-dd HH:mm:ss格式的时间
  static String? formatDateTime(DateTime? dateTime, {String? newPattern, String? locale}) {
    if (dateTime == null) {
      return null;
    }
    final dateFormat = DateFormat(newPattern ?? _dateTimePattern, locale);
    return dateFormat.format(dateTime);
  }

  /// 格式化时间戳为yyyy-MM-dd的时间
  static String? formatDateAsTimestamp(num? timestamp, {String? locale}) {
    return formatDateTimeAsTimestamp(timestamp, newPattern: _datePattern, locale: locale);
  }

  /// 格式化时间戳为yyyy-MM-dd HH:mm:ss格式的时间
  static String? formatDateTimeAsTimestamp(num? timestamp, {String? newPattern, String? locale}) {
    if (timestamp == null || timestamp == 0) {
      return null;
    }
    final dateFormat = DateFormat(newPattern ?? _dateTimePattern, locale);
    final timestampAsMilliseconds = (timestamp * Duration.millisecondsPerSecond).toInt();
    return dateFormat.format(DateTime.fromMillisecondsSinceEpoch(timestampAsMilliseconds));
  }

  /// 格式化时间间隔为xx时xx分xx秒的格式
  static String? formatDurationToSemantic(Duration? duration) {
    if (duration == null) {
      return null;
    }

    String format(int value) {
      return NumberFormat('00').format(value);
    }

    final days = duration.inDays;
    final hours = duration.inHours;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds;
    final formattedDuration = StringBuffer();
    if (days > 0) {
      formattedDuration.write('${format(days)}天');
    }
    if (hours > 0) {
      formattedDuration.write('${format(hours - days * Duration.hoursPerDay)}时');
    }
    if (minutes > 0) {
      formattedDuration.write('${format(minutes - hours * Duration.minutesPerHour)}分');
    }
    if (seconds > 0) {
      formattedDuration.write('${format(seconds - minutes * Duration.secondsPerMinute)}秒');
    }
    return formattedDuration.toString();
  }

  /// 获取格式化的文件大小
  /// [size]单位bytes
  static String formatMemory(int? size) {
    if (size == null) {
      return '0B';
    }

    const kb = 1024;
    const mb = kb * 1024;
    const gb = mb * 1024;
    const tb = gb * 1024;

    if (size >= tb) {
      return '${(size / tb).toStringAsFixed(0)}T';
    }
    if (size >= gb) {
      return '${(size / gb).toStringAsFixed(0)}G';
    }
    if (size >= mb) {
      return '${(size / mb).toStringAsFixed(0)}M';
    }
    if (size >= kb) {
      return '${(size / kb).toStringAsFixed(0)}K';
    }
    return '${size.toStringAsFixed(0)}B';
  }
}
