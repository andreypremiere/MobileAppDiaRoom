import '../enums/post_types.dart';

abstract class BlockPost {
  final BlockPostType type;

  BlockPost({required this.type});

  bool isEmpty();
}

abstract class BlockUpload {
  final BlockPostType type;

  BlockUpload({required this.type});

  Map<String, dynamic> toJson();
}