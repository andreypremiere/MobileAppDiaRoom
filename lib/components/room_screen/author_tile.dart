import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post_view/author.dart';
import '../general/app_avatar.dart';

class AuthorListTile extends StatelessWidget {
  final Author author;

  const AuthorListTile({super.key, required this.author});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/room/${author.roomId}'),
      leading: AppAvatar(avatarPath: author.avatar, radius: 22,),
      title: Text(
        author.roomName,
        style: TextStyle(
          color: context.ui.fontColorPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}