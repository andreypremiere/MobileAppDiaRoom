import '../enums/post_types.dart';
import 'block_post.dart';

class BlockPhotos extends BlockPost {
  List<String> paths;
  MethodViewPhoto methodView;
  static const limitPhotos = 10;

  bool get isFull => paths.length >= limitPhotos;

  BlockPhotos({List<String>? paths, this.methodView = MethodViewPhoto.tiles})
      : paths = paths ?? [],
        super(type: BlockPostType.photos);

  @override
  bool isEmpty() {
    if (paths.isEmpty) {
      return true;
    }
    return false;
  }

  bool addPath(String path) {
    if (paths.length >= limitPhotos) {
      return false;
    }
    paths.add(path);
    return true;
  }
}