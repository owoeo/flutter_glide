# flutter_glide

基于Flutter中`Image`类扩展的网络图片加载与本地图片加载,设计思路与灵感取于 [Cached network image](https://github.com/renefloor/flutter_cached_network_image) 和 [Glide](https://github.com/bumptech/glide).


## 插件的优点
- 使用`instantiateImageCodec`方法中的`targetWidth`跟`targetHeight`参数实现对源图片按需裁剪,不占用多余内存资源
- 单纯扩展`Image`类的功能与不足,对项目代码没有侵入性
- 支持缓存自定义实现,目前默认缓存使用[flutter_cache_manager](https://pub.dartlang.org/packages/flutter_cache_manager)
- 支持大部分图床按需裁剪图片的需求
## 简单使用
### 网络图片加载
你可以直接使用 Glide.network，与官方一致。
```dart
Glide.network(
  url,
  width: 100,
  height: 200,
  fit: BoxFit.fill,
)
```
### 本地图片加载
你可以直接使用 Glide.file，与官方一致。
```dart
Glide.file(
  file,
  width: 100,
  height: 200,
  fit: BoxFit.fill,
)
```
### 缓存自定义实现
例子
```dart
class DefaultImageCacheManager extends ImageCacheManager {
  @override
  Future<File> getSingleFile(String url, {Size size, double devicePixelRatio}) {
    return DefaultCacheManager().getSingleFile(url);
  }
}
//init
Glide.cacheManager = DefaultImageCacheManager();
```
### 实现图床按需加载
这里以阿里云OSS为例子
```dart
Glide.pathBuilder = (url, size, devicePixelRatio) => size.height >
        size.width
    ? '$url?x-oss-process=image/resize,h_${(size.height * devicePixelRatio).toInt()}'
    : '$url?x-oss-process=image/resize,w_${(size.width * devicePixelRatio).toInt()}';
```
## 写在最后
目前实现的功能较少,只满足目前项目开发,开源项目难免不足,希望有朋友能提出宝贵的意见
### 取这个名字的用意
说实在的取这个名字有点**大言不惭**

大家见谅,取这个名字主要希望在`Android`原生转`Flutter`方向的同学能加入,提高这个库的质量

