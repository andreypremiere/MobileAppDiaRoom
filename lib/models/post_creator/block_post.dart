import '../enums/post_types.dart';

abstract class BlockPost {
  final BlockPostType type;

  BlockPost({required this.type});

  bool isEmpty();
}