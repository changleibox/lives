// Copyright (c) 2022 CHANGLEI. All rights reserved.

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: Flutter Assets IDE plugin
// Made by Changlei
// **************************************************************************

// ignore: public_member_api_docs
class Assets {
  const Assets._();
  
  // ignore: public_member_api_docs
  static String images(String fileName) {
    return Images._(prefix: _Assets.instance.path).resolveFrom(fileName);
  }
}

class _Assets {
  _Assets._({this.prefix});

  final String? prefix;

  static _Assets get instance => _getInstance();
  static _Assets? _instance;

  static _Assets _getInstance() {
    _instance ??= _Assets._();
    return _instance!;
  }

  String get catalog => 'assets';

  String get path {
    final paths = <String>[];
    if (prefix != null && prefix!.isNotEmpty) {
      paths.add(prefix!);
    }
    paths.add(catalog);
    return paths.join('/');
  }

  String get pathEndsWithSeparator => path + '/';

  String resolveFrom(String fileName) {
    return [path, fileName].join('/');
  }
}

// ignore: public_member_api_docs
class Images extends _Assets {
  Images._({String? prefix}) : super._(prefix: prefix);

  // ignore: public_member_api_docs
  static const String tencent_cloud = 'tencent_cloud.png';

  // ignore: public_member_api_docs
  static const String loading = 'loading.png';

  @override
  String get catalog => 'images';
}
