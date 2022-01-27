// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'package:flutter/cupertino.dart';

/// Created by changlei on 2022/1/18.
///
/// 一个简陋的[CupertinoNavigationBar]
class CrudeNavigationBar extends StatelessWidget {
  /// 一个简陋的[CupertinoNavigationBar]
  const CrudeNavigationBar({
    Key? key,
    this.middle,
  }) : super(key: key);

  /// middle
  final Widget? middle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kMinInteractiveDimensionCupertino,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.clear,
                  color: CupertinoColors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.maybePop(context);
                },
              ),
            ),
            if (middle != null)
              Center(
                child: middle,
              ),
          ],
        ),
      ),
    );
  }
}
