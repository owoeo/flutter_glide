library flutter_glide;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'base_cache_manager.dart';
import 'glide_image_provider.dart';

typedef NetworkImagePathBuilder = String Function(
    String url, Size size, double devicePixelRatio);

class Glide extends StatefulWidget {
  static ImageCacheManager _cacheManage = DefaultImageCacheManager();

  static ImageCacheManager get cacheManager =>
      _cacheManage ?? DefaultImageCacheManager();

  static NetworkImagePathBuilder _pathBuilder;

  static set cacheManager(ImageCacheManager cacheManager) =>
      _cacheManage = cacheManager;

  static set pathBuilder(NetworkImagePathBuilder builder) =>
      _pathBuilder = builder;

  static NetworkImagePathBuilder get pathBuilder =>
      _pathBuilder ?? (url, size, devicePixelRatio) => url;

  final String image;
  final File file;
  final WidgetBuilder placeholder;
  final ImageLoadingBuilder loadingBuilder;
  final ImageFrameBuilder frameBuilder;
  final String semanticLabel;
  final bool excludeFromSemantics;
  final double width;
  final double height;
  final Color color;
  final BlendMode colorBlendMode;
  final BoxFit fit;
  final AlignmentGeometry alignment;
  final ImageRepeat repeat;
  final Rect centerSlice;
  final bool matchTextDirection;
  final bool gaplessPlayback;
  final FilterQuality filterQuality;

  Glide(
      {Key key,
      this.image,
      this.file,
      this.placeholder,
      this.loadingBuilder,
      this.frameBuilder,
      this.semanticLabel,
      this.excludeFromSemantics = false,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.gaplessPlayback = false,
      this.filterQuality = FilterQuality.low})
      : super(key: key);

  Glide.network(this.image,
      {Key key,
      this.placeholder,
      this.loadingBuilder,
      this.frameBuilder,
      this.semanticLabel,
      this.excludeFromSemantics = false,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.gaplessPlayback = false,
      this.filterQuality = FilterQuality.low})
      : file = null,
        super(key: key);

  Glide.file(this.file,
      {Key key,
      this.placeholder,
      this.loadingBuilder,
      this.frameBuilder,
      this.semanticLabel,
      this.excludeFromSemantics = false,
      this.width,
      this.height,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.alignment = Alignment.center,
      this.repeat = ImageRepeat.noRepeat,
      this.centerSlice,
      this.matchTextDirection = false,
      this.gaplessPlayback = false,
      this.filterQuality = FilterQuality.low})
      : image = null,
        super(key: key);

  @override
  _GlideState createState() => _GlideState();
}

class _GlideState extends State<Glide> {
  bool haveSize = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        haveSize = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox renderBoxRed = context.findRenderObject();
    return haveSize
        ? Image(
            loadingBuilder: widget.loadingBuilder,
            semanticLabel: widget.semanticLabel,
            excludeFromSemantics: widget.excludeFromSemantics,
            width: widget.width,
            height: widget.height,
            color: widget.color,
            colorBlendMode: widget.colorBlendMode,
            fit: widget.fit,
            alignment: widget.alignment,
            repeat: widget.repeat,
            centerSlice: widget.centerSlice,
            matchTextDirection: widget.matchTextDirection,
            gaplessPlayback: widget.gaplessPlayback,
            filterQuality: widget.filterQuality,
            image: GlideImageProvider(
                url: widget.image ?? '', widgetSize: renderBoxRed.size),
            frameBuilder: widget.frameBuilder ??
                (BuildContext context, Widget child, int frame,
                    bool wasSynchronouslyLoaded) {
                  if (widget.placeholder == null || wasSynchronouslyLoaded)
                    return child;
                  return AnimatedFadeOutFadeIn(
                    target: child,
                    placeholder: widget.placeholder(context),
                    isTargetLoaded: frame != null,
                    fadeOutDuration: const Duration(milliseconds: 300),
                    fadeOutCurve: Curves.easeOut,
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeInCurve: Curves.easeIn,
                  );
                },
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
