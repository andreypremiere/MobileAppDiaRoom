import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../general/app_avatar.dart';
import 'follow_button.dart';

class RoomHeader extends StatelessWidget {
  final bool isMyRoom;
  final String roomId;
  final String roomName;
  final String avatarUrl;
  final String backgroundUrl;

  const RoomHeader({
    super.key,
    required this.isMyRoom,
    required this.roomId,
    required this.roomName,
    required this.avatarUrl,
    required this.backgroundUrl,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: (backgroundUrl.isNotEmpty)
              ? DecorationImage(
            image: NetworkImage(backgroundUrl,
            ),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 15,
                left: 15,
                child: Text(
                  roomName,
                  style: TextStyle(
                    color: context.ui.fontColorLight,
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    shadows: const [
                      Shadow(
                        blurRadius: 15.0,
                        color: Colors.black54,
                        offset: Offset(1.0, 1.0),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      AppAvatar(avatarPath: avatarUrl, radius: 40,)
                    ],
                  ),
                ),
              ),
              !isMyRoom ? Positioned(bottom: 15, right: 15, child: FollowButton(roomId: roomId,)) : SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}