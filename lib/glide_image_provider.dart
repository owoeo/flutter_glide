import 'dart:async' show Future;
import 'dart:io' show File;
import 'dart:typed_data';
import 'dart:ui' as ui show instantiateImageCodec, Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'flutter_glide.dart';

class GlideImageProvider extends ImageProvider<GlideImageProvider> {
  GlideImageProvider(
      {this.url, this.file, this.scale: 1.0, this.widgetSize})
      : assert(url != null || file != null),
        assert(scale != null);

  final String url;

  final double scale;

  final Size widgetSize;

  final File file;

  double _devicePixelRatio = 1;

  Size configSize;

  @override
  ImageStream resolve(ImageConfiguration configuration) {
    _devicePixelRatio = configuration?.devicePixelRatio;
    double height = configuration.size?.height ?? 0;
    double width = configuration.size?.width ?? 0;
    if ((height > 0 && height < 100000) || (width > 0 && width < 100000))
      configSize = configuration.size;
    return super.resolve(configuration);
  }

  Size get size {
    if (configSize != null) {
      return configSize;
    } else {
      return widgetSize;
    }
  }

  @override
  Future<GlideImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<GlideImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(GlideImageProvider key) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: key.scale,
    );
  }

  Future<File> getImageFile() async {
    if (this.file == null) {
      return await Glide.cacheManager.getSingleFile(
          Glide.pathBuilder(url, size, _devicePixelRatio),
          size: size,
          devicePixelRatio: _devicePixelRatio);
    }
    return file;
  }

  Future<ui.Codec> _loadAsync(GlideImageProvider key) async {
    var file = await getImageFile();
    if (file == null) {
      return Future<ui.Codec>.error("Couldn't download or retrieve file.");
    }
    return await _loadAsyncFromFile(key, file);
  }

  Future<ui.Codec> _loadAsyncFromFile(GlideImageProvider key, File file) async {
    assert(key == this);

    final Uint8List bytes = await file.readAsBytes();

    if (bytes.lengthInBytes == 0) {
      throw Exception("File was empty");
    }
    print('crop image Size:$size DevicePixelRatio:$_devicePixelRatio');
    if ((size?.width ?? 0) == 0 && (size?.height ?? 0) == 0) {
      return await ui.instantiateImageCodec(bytes);
    } else if ((size?.width ?? 0) > (size?.height ?? 0)) {
      return await ui.instantiateImageCodec(bytes,
          targetWidth: (size.width * _devicePixelRatio).toInt());
    } else {
      return await ui.instantiateImageCodec(bytes,
          targetHeight: (size.height * _devicePixelRatio).toInt());
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final GlideImageProvider typedOther = other;

    return Glide.pathBuilder(url, size, _devicePixelRatio) ==
            Glide.pathBuilder(typedOther.url, size, _devicePixelRatio) &&
        file == typedOther.file &&
        scale == typedOther.scale;
  }

  @override
  int get hashCode =>
      hashValues(Glide.pathBuilder(url, size, _devicePixelRatio), scale, file);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
