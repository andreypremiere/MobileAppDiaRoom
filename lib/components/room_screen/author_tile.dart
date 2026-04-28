import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post_view/author.dart';

class AuthorListTile extends StatelessWidget {
  final Author author;

  const AuthorListTile({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/room/${author.roomId}'),
      leading: CachedNetworkImage(
        imageUrl: author.avatar,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          radius: 24,
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => const CircleAvatar(radius: 24, child: CircularProgressIndicator(strokeWidth: 2)),
        errorWidget: (context, url, error) => CircleAvatar(
          radius: 24,
          backgroundColor: context.ui.primaryColor,
          child: const Icon(Icons.person, color: Colors.white),
        ),
      ),
      title: Text(
        author.roomName,
        style: TextStyle(
          color: context.ui.fontColorPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      // trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.ui.fontColorHint),
    );
  }
}