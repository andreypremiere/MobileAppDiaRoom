import '../enums/post_types.dart';
import 'block_post.dart';

class BlockPhotos extends BlockPost {
  List<String> paths;
  MethodViewPhoto methodView;


  BlockPhotos({List<String>? paths, this.methodView = MethodViewPhoto.tiles})
      : paths = paths ?? [],
        super(type: BlockPostType.photos);
}