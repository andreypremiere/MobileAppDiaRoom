import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums/file_type.dart';
import '../../models/post_creator/block_video.dart';
import '../../utils/utils.dart';

class VideoPreviewWidget extends StatelessWidget {
  final BlockVideo block;

  const VideoPreviewWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    final bool isLocal = block.publicUrl.isEmpty && block.localPath.isNotEmpty;
    final String videoPath = isLocal ? block.localPath : getFullUrl(block.publicUrl);
    final String previewPath = isLocal ? block.previewLocalPath : getFullUrl(block.previewPublicUrl);

    return GestureDetector(
      onTap: () {
        context.push('/full_screen_video', extra: {
          'url': videoPath,
          'type': isLocal ? FileType.local : FileType.network,
        });
      },
      child: AspectRatio(
        aspectRatio: 1,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildPreviewImage(previewPath, isLocal),

              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: context.ui.fontColorLight,
                  size: 64,
                ),
              ),

              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    block.getFormattedDuration(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewImage(String path, bool isLocal) {
    if (isLocal) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildErrorIcon(),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: context.ui.containerColor.withAlpha(10),
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: context.ui.primaryColor,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorIcon(),
        fadeInDuration: const Duration(milliseconds: 200),
      );
    }
  }

  Widget _buildErrorIcon() {
    return Container(
      color: Colors.white10,
      child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
    );
  }
}