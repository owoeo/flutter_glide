import 'dart:io';

import 'dart:ui';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

abstract class ImageCacheManager {
  Future<File> getSingleFile(String url, {Size size, double devicePixelRatio});
}

class DefaultImageCacheManager extends ImageCacheManager {
  @override
  Future<File> getSingleFile(String url, {Size size, double devicePixelRatio}) {
    return DefaultCacheManager().getSingleFile(url);
  }
}
