import 'package:dia_room/models/post_creator/block_photos.dart';
import 'package:dia_room/models/post_creator/block_text.dart';
import 'package:dia_room/models/post_creator/block_video.dart';

import '../enums/post_types.dart';

abstract class BlockPost {
  final BlockType type;

  BlockPost({required this.type});

  factory BlockPost.fromMap(Map<String, dynamic> map) {
    final type = BlockType.fromMap(map);

    switch (type) {
      case BlockType.text:
        return TextBlockPost.fromMap(map);
      case BlockType.photos:
        return BlockPhotos.fromMap(map);
      case BlockType.videos:
        return BlockVideo.fromMap(map);
    }
  }
}

abstract class BlockUpload {
  final BlockType type;

  BlockUpload({required this.type});

  Map<String, dynamic> toJson();
}

abstract class Validatable {
  bool isEmpty();
  // Map<String, dynamic> toMap();
}