import 'package:dia_room/models/global_search/room_info.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/post_view/author.dart';
import '../general/app_avatar.dart';

class RoomTile extends StatelessWidget {
  final RoomInfo room;

  const RoomTile({super.key, required this.room});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () => context.push('/room/${room.id}'),
      leading: AppAvatar(imageUrl: room.avatarUrl),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          room.nickname,
          style: TextStyle(
            color: context.ui.fontColorPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text("@${room.roomUniqueId}",
          style: TextStyle(
            color: context.ui.fontColorHint,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),)
      ],)
    );
  }
}