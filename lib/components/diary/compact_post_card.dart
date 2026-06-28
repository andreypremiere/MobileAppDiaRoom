import 'package:flutter/material.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/post_view/base_post.dart';

class CompactPostCard extends StatelessWidget {
  final BasePost post;
  final VoidCallback onTap;

  const CompactPostCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: post.data.preview,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: context.ui.containerColor.withAlpha(120),
                    child: const Center(child: Icon(Icons.image_outlined, color: Colors.grey)),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: context.ui.containerColor,
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  ),
                ),
              ),

              Expanded(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.data.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.ui.fontColorPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          icon: Icons.favorite_border_rounded,
                          value: post.stats.likes.toString(),
                        ),
                        const SizedBox(width: 10),
                        _buildStatItem(
                          context,
                          icon: Icons.remove_red_eye_outlined,
                          value: post.stats.views.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {required IconData icon, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: context.ui.fontColorPrimary.withOpacity(0.5),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: context.ui.fontColorPrimary.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}