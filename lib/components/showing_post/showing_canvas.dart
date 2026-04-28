import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:flutter/material.dart';
import '../../models/enums/post_types.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_text.dart';
import '../../models/post_creator/block_video.dart';
import 'text_block_widget.dart';
import 'photos_block_widget.dart';
import 'video_preview_widget.dart';

class ShowingCanvas extends StatelessWidget {
  final List<BlockPost> blocks;
  final EdgeInsetsGeometry? padding;
  final double gap;
  final Widget? footer;

  const ShowingCanvas({
    super.key,
    required this.blocks,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
    this.footer,
    this.gap = 12,
  });

  @override
  Widget build(BuildContext context) {
    if (blocks.isEmpty) return const SizedBox.shrink();

    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return ListView.separated(
      shrinkWrap: true,
      itemCount: footer != null ? blocks.length + 1 : blocks.length,
      padding: padding?.add(EdgeInsets.only(bottom: bottomPadding + 20)),
      separatorBuilder: (context, index) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        if (footer != null && index == blocks.length) {
          return footer!;
        }

        final BlockPost block = blocks[index];
        return _resolveBlockWidget(block);
      },
    );
  }

  Widget _resolveBlockWidget(BlockPost block) {
    switch (block.type) {
      case BlockType.text:
        return TextBlockWidget(block: block as TextBlockPost);
      case BlockType.photos:
        return PhotosBlockWidget(block: block as BlockPhotos);
      case BlockType.videos:
        return VideoPreviewWidget(block: block as BlockVideo,);
    }
  }
}