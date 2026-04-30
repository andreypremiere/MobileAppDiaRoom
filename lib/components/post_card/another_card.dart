import 'package:dia_room/components/post_card/stats_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/post_view/base_post.dart';
import 'base_post_card.dart';

class AnotherPostComponent extends StatelessWidget {
  final BasePost post;

  const AnotherPostComponent({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BasePostCard(
      title: post.data.title,
      previewUrl: post.data.preview,
      category: post.data.category,
      onTap: () => context.push("/showPost/${post.data.postId}"),
      bottomPanel: Column(
        children: [
          Row(
            children: [
              const Spacer(),
              buildStats(context, post.stats.views, post.stats.likes),
            ],
          ),
        ],
      ),
    );
  }
}