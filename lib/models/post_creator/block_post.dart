import '../enums/post_types.dart';

abstract class BlockPost {
  final BlockType type;

  BlockPost({required this.type});

  bool isEmpty();
}

abstract class BlockUpload {
  final BlockType type;

  BlockUpload({required this.type});

  Map<String, dynamic> toJson();
}