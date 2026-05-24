import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../models/post_creator/block_post.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_text.dart';
import 'build_text_block.dart';
import 'build_photos_block.dart';
import 'build_video_block.dart';

class PostBlockWrapper extends StatelessWidget {
  final BlockPost block;
  final bool isFocused;

  // Колбэки для управления блоком из главного экрана
  final VoidCallback onFocus;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;
  final VoidCallback onChanged; // Для перерисовки (например, фото)

  const PostBlockWrapper({
    super.key,
    required this.block,
    required this.isFocused,
    required this.onFocus,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    required this.onChanged,
  });

  Widget _buildActionButton({
    required BuildContext context,
    required IconData iconData,
    required Color iconColor,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: 20,
        onPressed: onPressed,
        icon: Icon(iconData, color: iconColor),
      ),
    );
  }

  Widget _buildBlockContent() {
    if (block is BlockTextCreating) {
      return TextBlockWidget(
        block: block as BlockTextCreating,
        onFocus: onFocus,
      );
    }
    if (block is BlockPhotosCreating) {
      return PhotosBlockWidget(
        block: block as BlockPhotosCreating,
        onChanged: onChanged, // Передаем колбэк для обновления фото
      );
    }
    if (block is BlockVideoCreating) {
      return VideoBlockWidget(
        block: block as BlockVideoCreating,
        onChanged: onChanged,
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: ValueKey(block),
      behavior: HitTestBehavior.opaque,
      onTap: onFocus,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Сам контент с рамкой
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.ui.containerColor,
                border: Border.all(
                  color: isFocused ? context.ui.toolbarContainerColor : context.ui.fontColorHint,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildBlockContent(),
            ),

            // Панель управления (показывается только если в фокусе)
            if (isFocused)
              Container(
                margin: const EdgeInsets.only(top: 2, right: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(context: context,
                      iconData: Icons.arrow_circle_down,
                      iconColor: context.ui.toolbarContainerColor,
                      onPressed: onMoveDown,
                    ),
                    _buildActionButton(context: context,
                      iconData: Icons.arrow_circle_up,
                      iconColor: context.ui.toolbarContainerColor,
                      onPressed: onMoveUp,
                    ),
                    _buildActionButton(context: context,
                      iconData: Icons.delete_outline,
                      iconColor: Colors.redAccent,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}