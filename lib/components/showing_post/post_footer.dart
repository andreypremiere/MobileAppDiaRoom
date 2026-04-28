import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/auth_service.dart';
import '../follow_button.dart';
import 'like.dart';

class PostFooter extends StatelessWidget {
  final String postId;
  final String authorRoomId;
  final int likesCount;
  final int viewsCount;
  final List<String> hashtags;

  const PostFooter({
    super.key,
    required this.postId,
    required this.authorRoomId,
    required this.likesCount,
    required this.viewsCount,
    this.hashtags = const [],
  });

  @override
  Widget build(BuildContext context) {
    final currentUserRoomId = Provider.of<AuthProvider>(context, listen: false).roomId;

    final bool isAuthor = currentUserRoomId == authorRoomId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Divider(),

        // Хэштеги
        if (hashtags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 8,
              children: hashtags.map((tag) => Text(
                '#$tag',
                style: TextStyle(color: context.ui.fontColorPrimary, fontWeight: FontWeight.w500),
              )).toList(),
            ),
          ),

        Row(
          children: [
            LikeButton(postId: postId, initialCount: likesCount),
            const SizedBox(width: 24),

            // Просмотры
            Icon(Icons.visibility_outlined, size: 20, color: context.ui.fontColorHint),
            const SizedBox(width: 4),
            Text('$viewsCount', style: TextStyle(color: context.ui.fontColorHint)),

            const Spacer(),

            if (!isAuthor)
              FollowButton(roomId: authorRoomId),
          ],
        ),
      ],
    );
  }
}