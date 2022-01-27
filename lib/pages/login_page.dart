// Copyright (c) 2022 CHANGLEI. All rights reserved.

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_grasp/flutter_grasp.dart';
import 'package:lives/commons/test_data.dart';
import 'package:lives/models/live_error.dart';
import 'package:lives/models/lives.dart';
import 'package:lives/routes/routes.dart';
import 'package:lives/widgets/future_wrapper.dart';
import 'package:oktoast/oktoast.dart';

/// Created by changlei on 2022/1/18.
///
/// 登录页面
class LoginPage extends StatefulWidget with HostProvider {
  /// 构建登录页面，用来登录腾讯云
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();

  @override
  _LoginPresenter createPresenter() => _LoginPresenter();
}

class _LoginPageState extends HostState<LoginPage, _LoginPresenter> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('登录'),
      ),
      child: Align(
        alignment: const Alignment(0, -0.22),
        child: SingleChildScrollView(
          child: WidgetGroup.spacing(
            alignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            direction: Axis.vertical,
            children: [
              Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(
                    side: BorderSide(
                      color: CupertinoColors.separator,
                      width: 0,
                    ),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: CachedNetworkImage(
                  imageUrl: avatar,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                '测试${presenter._userId}号',
                style: const TextStyle(
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                '将使用指定ID登录腾讯云',
                style: TextStyle(
                  color: CupertinoColors.systemGrey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 48,
              ),
              CupertinoButton.filled(
                minSize: 40,
                borderRadius: BorderRadius.circular(6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 64,
                ),
                onPressed: presenter._login,
                child: const Text('确认登录'),
              ),
              const SizedBox(
                height: 24,
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minSize: 0,
                onPressed: presenter._cancel,
                child: const Text('取消'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginPresenter extends Presenter<LoginPage> {
  late String _userId;

  @override
  void initState() {
    _userId = Random().nextInt(100).toString();
    super.initState();
  }

  Future<void> _login() async {
    try {
      await FutureWrapper.wrapLoading(
        context: context,
        computation: () {
          return Lives.login(_userId);
        },
      );
      unawaited(Routes.home.pushNamedAndRemoveUntil(context, (route) => false));
    } on LiveError catch (e) {
      showToast(e.message.toString());
    }
  }

  void _cancel() {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          content: const Text('确定取消登录'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                exit(0);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}
