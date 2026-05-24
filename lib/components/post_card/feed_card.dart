import 'package:dia_room/components/post_card/stats_widget.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/post_view/feed_post.dart';
import '../general/app_avatar.dart';
import 'base_post_card.dart';

class FeedPostComponent extends StatelessWidget {
  final FeedPost post;

  const FeedPostComponent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BasePostCard(
      title: post.data.title,
      previewUrl: post.data.preview,
      category: post.data.category,
      onTap: () => context.push("/showPost/${post.data.roomId}/${post.data.postId}"),
      bottomPanel: Column(
        children: [
          Row(
            children: [
              _buildAuthorInfo(context),
              const Spacer(),
              buildStats(context, post.stats.views, post.stats.likes),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppAvatar(radius: 12, avatarPath: post.author.avatar,),
        const SizedBox(width: 8),
        Text(
          post.author.roomName,
          style: TextStyle(
            color: context.ui.fontColorHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
