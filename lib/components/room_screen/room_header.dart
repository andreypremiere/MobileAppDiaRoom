// components/room/room_header.dart
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class RoomHeader extends StatelessWidget {
  final String roomName;
  final String avatarUrl;
  final String backgroundUrl;

  const RoomHeader({
    super.key,
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
        // height: 220,
        decoration: BoxDecoration(
          image: (backgroundUrl.isNotEmpty)
              ? DecorationImage(
            image: NetworkImage(backgroundUrl,
            ), // Или NetworkImage
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
              // Название комнаты поверх обложки с тенью для читаемости
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
              // Аватар и блок спонсора
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                          radius: 40,
                          backgroundColor: context.ui.fontColorHint,
                          backgroundImage:
                          (avatarUrl.isNotEmpty)
                              ? NetworkImage(
                            avatarUrl,
                          ) : null
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}