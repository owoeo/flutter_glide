import 'package:flutter/painting.dart';

class GlideImage extends ResizeImage {
  GlideImage(
    ImageProvider imageProvider, {
    int width,
    int height,
  }) : super(
          imageProvider,
          width: width,
          height: height,
        );

  /// Composes the `provider` in a [ResizeImage] only when `cacheWidth` and
  /// `cacheHeight` are not both null.
  ///
  /// When `cacheWidth` and `cacheHeight` are both null, this will return the
  /// `provider` directly.
  static ImageProvider<dynamic> resizeIfNeeded(
      int cacheWidth, int cacheHeight, ImageProvider<dynamic> provider) {
    if (cacheWidth != null || cacheHeight != null) {
      return GlideImage(provider, width: cacheWidth, height: cacheHeight);
    }
    return provider;
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final GlideImage typedOther = other;

    return typedOther.width == width &&
        typedOther.height == height &&
        typedOther.imageProvider == imageProvider;
  }

  @override
  int get hashCode => hashValues(width, height, imageProvider);
}
