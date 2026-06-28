import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../loading_widget/loader_widget.dart';

class SelectablePostCard extends StatelessWidget {
  final PostResponse post;
  final VoidCallback? onTap;

  const SelectablePostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String? finalImageUrl;
    if (post.files.isNotEmpty) {
      final rawUrl = post.files.first.urlSmall;
      if (rawUrl != null && rawUrl.isNotEmpty) {
        finalImageUrl = rawUrl.startsWith('http')
            ? rawUrl
            : 'https://storage.yandexcloud.net/$rawUrl';
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.ui.containerColor,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: 1.0,
              child: finalImageUrl != null
                  ? CachedNetworkImage(
                imageUrl: finalImageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: const Center(
                    child: DiaRoomLoader(),
                  ),
                ),
                errorWidget: (context, url, error) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                  );
                },
              )
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Spacer(),
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: context.ui.fontColorHint,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${post.commentsCount}",
                    style: TextStyle(
                      fontSize: 13,
                      color: context.ui.fontColorHint,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: post.isLiked ? Colors.redAccent : context.ui.fontColorHint,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.likesCount}',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.ui.fontColorHint,
                    ),
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