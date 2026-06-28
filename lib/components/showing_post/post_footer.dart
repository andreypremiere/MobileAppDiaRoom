import 'package:dia_room/models/post_creator/workshop_link.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../configuration/constants.dart';
import '../../utils/auth_service.dart';
import '../diary/link_button.dart';
import '../diary/panel_link_buttons.dart';
import '../room_screen/follow_button.dart';
import 'like.dart';

class PostFooter extends StatelessWidget {
  final String postId;
  final String authorRoomId;
  final int likesCount;
  final int viewsCount;
  final List<String> hashtags;
  final WorkshopLink workshopLink;

  const PostFooter({
    super.key,
    required this.postId,
    required this.authorRoomId,
    required this.likesCount,
    required this.viewsCount,
    this.hashtags = const [],
    required this.workshopLink,
  });

  void _handleOnTapWorkshop(BuildContext context) {
    final workshopId = workshopLink.getLink();
    final roomId = authorRoomId;

    if (workshopId == null) return;

    final String path = (workshopId == uuidNil)
        ? '/workshop/$roomId'
        : '/workshop/$roomId/$workshopId';

    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final currentUserRoomId = Provider.of<AuthProvider>(
      context,
      listen: false,
    ).roomId;

    final bool isAuthor = currentUserRoomId == authorRoomId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workshopLink.isExist())
          CustomLinkButton(
            icon: Icons.burst_mode_outlined,
            label: "Открыть в мастерской",
            onTap: () => _handleOnTapWorkshop(context),
          ),

        if (hashtags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Wrap(
              spacing: 8,
              children: hashtags
                  .map(
                    (tag) => Text(
                      '#$tag',
                      style: TextStyle(
                        color: context.ui.fontColorPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

        Row(
          children: [
            LikeButton(postId: postId, initialCount: likesCount),
            const SizedBox(width: 24),

            Icon(
              Icons.visibility_outlined,
              size: 20,
              color: context.ui.fontColorHint,
            ),
            const SizedBox(width: 4),
            Text(
              '$viewsCount',
              style: TextStyle(color: context.ui.fontColorHint),
            ),

            const Spacer(),

            if (!isAuthor) FollowButton(roomId: authorRoomId),
          ],
        ),
      ],
    );
  }
}
