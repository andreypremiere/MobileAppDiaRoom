import 'package:dia_room/models/enums/global_search/global_search_method.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/app_theme.dart';

class PostHashtags extends StatelessWidget {
  final List<String> hashtags;

  const PostHashtags({super.key, required this.hashtags});

  @override
  Widget build(BuildContext context) {
    if (hashtags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 4.0,
        children: hashtags.map((tag) {
          final formattedTag = tag.startsWith('#') ? tag : '#$tag';

          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/search?text=${tag}&method=${GlobalSearchMethod.postV2.name}');
              },
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 1.0),
                child: Text(
                  formattedTag,
                  style: TextStyle(
                    color: context.ui.fontColorPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}