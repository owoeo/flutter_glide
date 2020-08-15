library flutter_glide;

export 'src/image_provider.dart';
export 'src/base_cache_manager.dart';
export 'src/cache_image_provider.dart';

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'src/base_cache_manager.dart';
import 'src/cache_image_provider.dart';
import 'src/image_provider.dart';

typedef NetworkImageUrlBuilder = String Function(
  String url,
  double width,
  double height,
  double devicePixelRatio,
);

class Glide {
  static BaseCacheManager _cacheManage = DefaultImageCacheManager();

  static BaseCacheManager get cacheManager =>
      _cacheManage ?? DefaultImageCacheManager();

  static NetworkImageUrlBuilder _pathBuilder;

  static set cacheManager(BaseCacheManager cacheManager) =>
      _cacheManage = cacheManager;

  static set pathBuilder(NetworkImageUrlBuilder builder) =>
      _pathBuilder = builder;

  static NetworkImageUrlBuilder get pathBuilder =>
      _pathBuilder ?? (url, size, devicePixelRatio) => url;

  static Widget image(
    ImageProvider image, {
    Key key,
    WidgetBuilder placeholder,
    ImageLoadingBuilder loadingBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return SizeImage((context, maxWidth, maxHeight) => Image(
          key: key,
          loadingBuilder: loadingBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          filterQuality: filterQuality,
          image: GlideImage.resizeIfNeeded(
              maxWidth?.toInt(), maxHeight?.toInt(), image),
          frameBuilder: (BuildContext context, Widget child, int frame,
              bool wasSynchronouslyLoaded) {
            if (placeholder == null || wasSynchronouslyLoaded) return child;
            return AnimatedFadeOutFadeIn(
              target: child,
              placeholder: placeholder(context),
              isTargetLoaded: frame != null,
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeOutCurve: Curves.easeOut,
              fadeInDuration: const Duration(milliseconds: 500),
              fadeInCurve: Curves.easeIn,
            );
          },
        ));
  }

  static Widget network(
    String url, {
    Key key,
    WidgetBuilder placeholder,
    ImageLoadingBuilder loadingBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
    bool checkCache = false,
  }) {
    return SizeImage((context, maxWidth, maxHeight) => Image(
          key: key,
          loadingBuilder: loadingBuilder,
          semanticLabel: semanticLabel,
          excludeFromSemantics: excludeFromSemantics,
          width: width,
          height: height,
          color: color,
          colorBlendMode: colorBlendMode,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          centerSlice: centerSlice,
          matchTextDirection: matchTextDirection,
          gaplessPlayback: gaplessPlayback,
          filterQuality: filterQuality,
          image: GlideImage.resizeIfNeeded(
            maxWidth?.toInt(),
            maxHeight?.toInt(),
            CacheImage(
              Glide.pathBuilder(
                url,
                maxWidth,
                maxHeight,
                MediaQuery.of(context).devicePixelRatio,
              ),
              checkCache: checkCache,
              cacheManager: Glide.cacheManager,
            ),
          ),
          frameBuilder: (BuildContext context, Widget child, int frame,
              bool wasSynchronouslyLoaded) {
            if (placeholder == null || wasSynchronouslyLoaded) return child;
            return AnimatedFadeOutFadeIn(
              target: child,
              placeholder: placeholder(context),
              isTargetLoaded: frame != null,
              fadeOutDuration: const Duration(milliseconds: 300),
              fadeOutCurve: Curves.easeOut,
              fadeInDuration: const Duration(milliseconds: 500),
              fadeInCurve: Curves.easeIn,
            );
          },
        ));
  }

  static Widget file(
    File file, {
    Key key,
    WidgetBuilder placeholder,
    ImageLoadingBuilder loadingBuilder,
    String semanticLabel,
    bool excludeFromSemantics = false,
    double width,
    double height,
    Color color,
    BlendMode colorBlendMode,
    BoxFit fit = BoxFit.cover,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    FilterQuality filterQuality = FilterQuality.low,
  }) {
    return SizeImage(
      (context, maxWidth, maxHeight) => Image(
        key: key,
        loadingBuilder: loadingBuilder,
        semanticLabel: semanticLabel,
        excludeFromSemantics: excludeFromSemantics,
        width: width,
        height: height,
        color: color,
        colorBlendMode: colorBlendMode,
        fit: fit,
        alignment: alignment,
        repeat: repeat,
        centerSlice: centerSlice,
        matchTextDirection: matchTextDirection,
        gaplessPlayback: gaplessPlayback,
        filterQuality: filterQuality,
        image: GlideImage.resizeIfNeeded(
          maxWidth?.toInt(),
          maxHeight?.toInt(),
          FileImage(file),
        ),
        frameBuilder: (BuildContext context, Widget child, int frame,
            bool wasSynchronouslyLoaded) {
          if (placeholder == null || wasSynchronouslyLoaded) return child;
          return AnimatedFadeOutFadeIn(
            target: child,
            placeholder: placeholder(context),
            isTargetLoaded: frame != null,
            fadeOutDuration: const Duration(milliseconds: 300),
            fadeOutCurve: Curves.easeOut,
            fadeInDuration: const Duration(milliseconds: 700),
            fadeInCurve: Curves.easeIn,
          );
        },
      ),
    );
  }
}

typedef WidgetSizeBuilder = Widget Function(
    BuildContext context, double width, double height);

class SizeImage extends StatefulWidget {
  final WidgetSizeBuilder builder;

  SizeImage(this.builder);

  @override
  _SizeImageState createState() => _SizeImageState();
}

class _SizeImageState extends State<SizeImage> {
  bool _measured = false;
  RenderBox _renderBoxRed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _measured = true;
      });
    });
  }

  double get width {
    _renderBoxRed ??= context.findRenderObject();
    if (_renderBoxRed.size.width >= _renderBoxRed.size.height &&
        _renderBoxRed.size.width < 4000) {
      return _renderBoxRed.size.width != 0 ? _renderBoxRed.size.width : null;
    } else {
      return null;
    }
  }

  double get height {
    _renderBoxRed ??= context.findRenderObject();
    if (_renderBoxRed.size.height > _renderBoxRed.size.width &&
        _renderBoxRed.size.height < 4000) {
      return _renderBoxRed.size.height != 0 ? _renderBoxRed.size.height : null;
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ratio = MediaQuery.of(context).devicePixelRatio;
    return _measured && widget.builder != null
        ? widget.builder(
            context,
            width != null ? width * ratio : null,
            height != null ? height * ratio : null,
          )
        : Container();
  }
}

class AnimatedFadeOutFadeIn extends ImplicitlyAnimatedWidget {
  const AnimatedFadeOutFadeIn({
    Key key,
    @required this.target,
    @required this.placeholder,
    @required this.isTargetLoaded,
    @required this.fadeOutDuration,
    @required this.fadeOutCurve,
    @required this.fadeInDuration,
    @required this.fadeInCurve,
  })  : assert(target != null),
        assert(placeholder != null),
        assert(isTargetLoaded != null),
        assert(fadeOutDuration != null),
        assert(fadeOutCurve != null),
        assert(fadeInDuration != null),
        assert(fadeInCurve != null),
        super(key: key, duration: fadeInDuration + fadeOutDuration);

  final Widget target;
  final Widget placeholder;
  final bool isTargetLoaded;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;

  @override
  _AnimatedFadeOutFadeInState createState() => _AnimatedFadeOutFadeInState();
}

class _AnimatedFadeOutFadeInState
    extends ImplicitlyAnimatedWidgetState<AnimatedFadeOutFadeIn> {
  Tween<double> _targetOpacity;
  Tween<double> _placeholderOpacity;
  Animation<double> _targetOpacityAnimation;
  Animation<double> _placeholderOpacityAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _targetOpacity = visitor(
      _targetOpacity,
      widget.isTargetLoaded ? 1.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value),
    );
    _placeholderOpacity = visitor(
      _placeholderOpacity,
      widget.isTargetLoaded ? 0.0 : 1.0,
      (dynamic value) => Tween<double>(begin: value),
    );
  }

  @override
  void didUpdateTweens() {
    _placeholderOpacityAnimation =
        animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween:
            _placeholderOpacity.chain(CurveTween(curve: widget.fadeOutCurve)),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]));
    _targetOpacityAnimation =
        animation.drive(TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0),
        weight: widget.fadeOutDuration.inMilliseconds.toDouble(),
      ),
      TweenSequenceItem<double>(
        tween: _targetOpacity.chain(CurveTween(curve: widget.fadeInCurve)),
        weight: widget.fadeInDuration.inMilliseconds.toDouble(),
      ),
    ]));
    if (!widget.isTargetLoaded &&
        _isValid(_placeholderOpacity) &&
        _isValid(_targetOpacity)) {
      // Jump (don't fade) back to the placeholder image, so as to be ready
      // for the full animation when the new target image becomes ready.
      controller.value = controller.upperBound;
    }
  }

  bool _isValid(Tween<double> tween) {
    return tween.begin != null && tween.end != null;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: AlignmentDirectional.center,
      // Text direction is irrelevant here since we're using center alignment,
      // but it allows the Stack to avoid a call to Directionality.of()
      textDirection: TextDirection.ltr,
      children: <Widget>[
        FadeTransition(
          opacity: _targetOpacityAnimation,
          child: widget.target,
        ),
        FadeTransition(
          opacity: _placeholderOpacityAnimation,
          child: widget.placeholder,
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Animation<double>>(
        'targetOpacity', _targetOpacityAnimation));
    properties.add(DiagnosticsProperty<Animation<double>>(
        'placeholderOpacity', _placeholderOpacityAnimation));
  }
}
