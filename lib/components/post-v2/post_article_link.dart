import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../diary/link_button.dart';

class PostArticleLink extends StatelessWidget {
  final String? articleLink;
  final String roomId;

  const PostArticleLink({super.key, this.articleLink, required this.roomId});

  @override
  Widget build(BuildContext context) {
    if (articleLink == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 6),
      child: CustomLinkButton(
        icon: Icons.article_outlined,
        label: 'Открыть статью',
        onTap: () {
          if (articleLink == null) return;
          final String path = "/showPost/$roomId/$articleLink";
          context.push(path);
        },
      ),
    );
  }
}