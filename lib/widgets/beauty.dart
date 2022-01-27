// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:lives/enums/beauty_type.dart';
import 'package:lives/models/lives.dart';
import 'package:provider/provider.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/tx_beauty_manager.dart';

const _animationDuration = Duration(
  milliseconds: 150,
);

/// Created by changlei on 2022/1/26.
///
/// 美颜弹窗
class Beauty extends StatefulWidget {
  /// 构建美颜弹窗
  const Beauty({
    Key? key,
    required this.manager,
    this.initialBeauty = const {},
    this.onChanged,
  }) : super(key: key);

  /// 美颜管理器
  final TXBeautyManager manager;

  /// 初始数据
  final Map<BeautyType, int> initialBeauty;

  /// 变更回调
  final ValueChanged<Map<BeautyType, int>>? onChanged;

  @override
  State<Beauty> createState() => _BeautyState();
}

class _BeautyState extends State<Beauty> {
  final _beautyValue = <BeautyType, int>{};

  BeautyType _groupValue = BeautyType.smooth;

  @override
  void initState() {
    super.initState();
    _beautyValue.addAll(widget.initialBeauty);
  }

  @override
  void didUpdateWidget(covariant Beauty oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapEquals(widget.initialBeauty, oldWidget.initialBeauty)) {
      _beautyValue.addAll(widget.initialBeauty);
    }
  }

  Widget _buildItem(BeautyType value) {
    final selected = _groupValue == value;
    final primaryColor = CupertinoTheme.of(context).primaryColor;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: AnimatedDefaultTextStyle(
        duration: _animationDuration,
        style: TextStyle(
          color: primaryColor.withOpacity(selected ? 1 : 0.5),
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          fontSize: 14,
        ),
        child: AnimatedScale(
          duration: _animationDuration,
          scale: selected ? 1.0 : 0.95,
          child: Text(value.label),
        ),
      ),
    );
  }

  void _onBeautyValueChange(BeautyType groupValue, double value) {
    final manager = widget.manager;
    if (groupValue == BeautyType.smooth || groupValue == BeautyType.nature || groupValue == BeautyType.pitu) {
      if (BeautyType.smooth == groupValue) {
        manager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_SMOOTH);
      } else if (BeautyType.nature == groupValue) {
        manager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_NATURE);
      } else if (BeautyType.pitu == groupValue) {
        manager.setBeautyStyle(TRTCCloudDef.TRTC_BEAUTY_STYLE_PITU);
      }
      manager.setBeautyLevel(value.round());
    } else if (groupValue == BeautyType.whitening) {
      manager.setWhitenessLevel(value.round());
    } else if (groupValue == BeautyType.ruddy) {
      manager.setRuddyLevel(value.round());
    }
    widget.onChanged?.call(Map.unmodifiable(_beautyValue));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xdd1e1d27),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(8),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          margin: const EdgeInsets.only(
            top: 10,
            bottom: 16,
          ),
          child: WidgetGroup.spacing(
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            spacing: 16,
            children: [
              CupertinoSegmentedControl<BeautyType>(
                pressedColor: CupertinoColors.white.withOpacity(0),
                borderColor: CupertinoColors.white.withOpacity(0),
                selectedColor: CupertinoColors.white.withOpacity(0),
                unselectedColor: CupertinoColors.white.withOpacity(0),
                groupValue: _groupValue,
                padding: EdgeInsets.zero,
                onValueChanged: (value) {
                  setState(() {
                    _groupValue = value;
                  });
                },
                children: Map.fromEntries(BeautyType.values.map((e) => MapEntry(e, _buildItem(e)))),
              ),
              WidgetGroup.spacing(
                spacing: 10,
                children: [
                  const Text(
                    '强度',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                  Expanded(
                    child: CupertinoSlider(
                      value: _beautyValue[_groupValue]!.toDouble(),
                      min: 0,
                      max: 9,
                      divisions: 9,
                      onChanged: (double value) {
                        setState(() {
                          _beautyValue[_groupValue] = value.toInt();
                        });
                        _onBeautyValueChange(_groupValue, value);
                      },
                    ),
                  ),
                  Text(
                    _beautyValue[_groupValue]!.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: CupertinoColors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示美颜弹窗
Future<void> showBeauty(BuildContext context, TXBeautyManager manager) {
  final model = context.read<LiveModel>();
  return showCupertinoModalPopup<void>(
    context: context,
    builder: (context) {
      return Beauty(
        manager: manager,
        initialBeauty: model.beauty,
        onChanged: (value) {
          model.beauty = value;
        },
      );
    },
  );
}
