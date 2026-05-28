import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums/file_type.dart';

class AppAvatar extends StatelessWidget {
  final String? avatarPath;
  final int? avatarVersion;
  final double radius;
  final bool enableFullScreenPreview;
  final FileType fileType;

  const AppAvatar({
    super.key,
    required this.avatarPath,
    this.avatarVersion,
    this.radius = 100,
    this.enableFullScreenPreview = true,
    this.fileType = FileType.network,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = avatarPath != null && avatarPath!.isNotEmpty;
    final double diameter = radius * 2;

    // Выносим декор для состояния ошибки/отсутствия картинки,
    // чтобы не дублировать код в дереве виджетов.
    final placeholderDecoration = BoxDecoration(
      color: const Color(0xFFF0F0F0),
      shape: BoxShape.circle,
    );

    return GestureDetector(
      onTap: (hasImage && enableFullScreenPreview)
          ? () {
        context.push(
          '/full_image_screen',
          extra: {
            'urls': [avatarPath.toString()],
            'index': 0,
            'type': fileType,
          },
        );
      }
          : null,
      child: SizedBox(
        height: diameter,
        width: diameter,
        child: hasImage
            ? ClipOval(
          child: CachedNetworkImage(
            key: ValueKey('$avatarPath-${avatarVersion ?? 0}'),
            imageUrl: avatarPath!,
            fit: BoxFit.cover,
            placeholder: (context, url) =>
            const Center(child: DiaRoomLoader()),
            errorWidget: (context, url, error) => Container(
              decoration: placeholderDecoration,
              child: Icon(
                Icons.error,
                color: Colors.grey,
                size: radius,
              ),
            ),
          ),
        )
            : Container(
          decoration: placeholderDecoration,
          child: Center(
            child: Icon(
              Icons.person,
              color: Colors.grey,
              size: radius,
            ),
          ),
        ),
      ),
    );
  }
}