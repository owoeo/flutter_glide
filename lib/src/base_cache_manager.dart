import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DefaultImageCacheManager extends BaseCacheManager {
  static const key = 'libCachedImageData';

  static const maxAge = Duration(days: 3);

  static DefaultImageCacheManager _instance;

  factory DefaultImageCacheManager() {
    _instance ??= DefaultImageCacheManager._();
    return _instance;
  }

  DefaultImageCacheManager._() : super(key, maxAgeCacheObject: maxAge);

  @override
  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return p.join(directory.path, key);
  }
}
