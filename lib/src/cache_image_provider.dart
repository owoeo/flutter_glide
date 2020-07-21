import 'dart:async' show Future, StreamController;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as image_provider
    show
        NetworkImage,
        DecoderCallback,
        ImageConfiguration,
        ImageProvider,
        NetworkImageLoadException;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import '../flutter_glide.dart';

/// The dart:io implementation of [image_provider.NetworkImage].
class CacheImage extends ImageProvider<image_provider.NetworkImage>
    implements image_provider.NetworkImage {
  /// Creates an object that fetches the image at the given URL.
  ///
  /// The arguments [url] and [scale] must not be null.
  const CacheImage(
    this.url, {
    this.scale = 1.0,
    this.headers,
    this.cacheManager,
    this.checkCache = false,
  })  : assert(url != null),
        assert(scale != null);

  @override
  final String url;

  @override
  final double scale;

  @override
  final Map<String, String> headers;

  final BaseCacheManager cacheManager;

  final bool checkCache;

  @override
  Future<NetworkImage> obtainKey(
      image_provider.ImageConfiguration configuration) {
    return SynchronousFuture<NetworkImage>(this);
  }

  @override
  ImageStreamCompleter load(
      image_provider.NetworkImage key, image_provider.DecoderCallback decode) {
    // Ownership of this controller is handed off to [_loadAsync]; it is that
    // method's responsibility to close the controller's stream when the image
    // has been loaded or an error is thrown.
    final StreamController<ImageChunkEvent> chunkEvents =
        StreamController<ImageChunkEvent>();

    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, chunkEvents, decode),
      chunkEvents: chunkEvents.stream,
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<image_provider.ImageProvider>(
              'Image provider', this),
          DiagnosticsProperty<image_provider.NetworkImage>('Image key', key),
        ];
      },
    );
  }

  // Do not access this field directly; use [_httpClient] instead.
  // We set `autoUncompress` to false to ensure that we can trust the value of
  // the `Content-Length` HTTP header. We automatically uncompress the content
  // in our call to [consolidateHttpClientResponseBytes].
  static final HttpClient _sharedHttpClient = HttpClient()
    ..autoUncompress = false;

  static HttpClient get _httpClient {
    HttpClient client = _sharedHttpClient;
    assert(() {
      if (debugNetworkImageHttpClientProvider != null)
        client = debugNetworkImageHttpClientProvider();
      return true;
    }());
    return client;
  }

  Future<bool> _checkCache(Uri resolved, FileInfo cache) async {
    if (!checkCache) return true;
    try {
      final HttpClientRequest headRequest = await _httpClient.headUrl(resolved);
      final HttpClientResponse response = await headRequest.close();
      if (response.statusCode != HttpStatus.ok) {
        return true;
      }
      DateTime updateTime =
          HttpDate.parse(response.headers.value('last-modified'));
      return cache.validTill
          .subtract(DefaultImageCacheManager.maxAge)
          .isAfter(updateTime);
    } catch (e) {
      return true;
    }
  }

  Future<ui.Codec> _loadAsync(
    NetworkImage key,
    StreamController<ImageChunkEvent> chunkEvents,
    image_provider.DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      final FileInfo cache = await cacheManager?.getFileFromCache(key.url);
      final Uri resolved = Uri.base.resolve(key.url);

      if (cache != null && await _checkCache(resolved, cache)) {
        return decode(await cache.file.readAsBytes());
      }
      final HttpClientRequest request = await _httpClient.getUrl(resolved);
      headers?.forEach((String name, String value) {
        request.headers.add(name, value);
      });
      final HttpClientResponse response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw image_provider.NetworkImageLoadException(
            statusCode: response.statusCode, uri: resolved);

      final Uint8List bytes = await consolidateHttpClientResponseBytes(
        response,
        onBytesReceived: (int cumulative, int total) {
          chunkEvents.add(ImageChunkEvent(
            cumulativeBytesLoaded: cumulative,
            expectedTotalBytes: total,
          ));
        },
      );
      if (bytes.lengthInBytes == 0)
        throw Exception('NetworkImage is an empty file: $resolved');
      await cacheManager?.putFile(key.url, bytes,
          maxAge: DefaultImageCacheManager.maxAge);
      return decode(bytes);
    } catch (e) {
      ImageCache().evict(key);
      rethrow;
    } finally {
      chunkEvents.close();
    }
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final NetworkImage typedOther = other;
    return url == typedOther.url && scale == typedOther.scale;
  }

  @override
  int get hashCode => ui.hashValues(url, scale);

  @override
  String toString() => '$runtimeType("$url", scale: $scale)';
}
