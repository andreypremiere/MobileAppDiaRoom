import 'package:dia_room/components/showing_post/photo_tile_item.dart';
import 'package:dia_room/components/showing_post/slider_block.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums/file_type.dart';
import '../../models/enums/method_view_photo.dart';
import '../../models/post_creator/block_photos.dart';
import '../../utils/utils.dart';

class PhotosBlockWidget extends StatelessWidget {
  final BlockPhotos block;

  const PhotosBlockWidget({super.key, required this.block});

  @override
  Widget build(BuildContext context) {
    if (block.listPhoto.isEmpty) return const SizedBox.shrink();

    // Определяем тип данных по первой фотографии
    final bool isLocal = block.listPhoto.first.publicUrl.isEmpty &&
        block.listPhoto.first.filePath.isNotEmpty;

    // Формируем список путей/ссылок
    final List<String> paths = block.listPhoto
        .map((e) => isLocal ? e.filePath : getFullUrl(e.publicUrl))
        .toList();

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(context.ui.borderRadiusMedium),
        child: block.methodView == MethodViewPhoto.slider
            ? PhotoSlider(
          urls: paths,
          isLocal: isLocal,
          onTap: (index) => _openGalleryPreview(context, paths, index, isLocal),
        )
            : _buildPhotoTiles(context, paths, isLocal),
      ),
    );
  }

  // Универсальный метод открытия галереи
  void _openGalleryPreview(BuildContext context, List<String> paths, int startIndex, bool isLocal) {
    context.push('/full_image_screen', extra: {
      'urls': paths,
      'index': startIndex,
      'type': isLocal ? FileType.local : FileType.network,
    });
  }

  Widget _buildPhotoTiles(BuildContext context, List<String> paths, bool isLocal) {
    Widget buildItem(int index) {
      return PhotoTileItem(
        path: paths[index],
        allPaths: paths,
        index: index,
        isLocal: isLocal,
        onTap: () => _openGalleryPreview(context, paths, index, isLocal),
      );
    }

    int count = paths.length;

    if (count == 1) return buildItem(0);

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: buildItem(0),),
          const SizedBox(width: 2),
          Expanded(child: buildItem(1)),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(child: buildItem(0)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: buildItem(1)),
                const SizedBox(height: 2),
                Expanded(child: buildItem(2)),
              ],
            ),
          ),
        ],
      );
    }

    // 4 и более фото
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: buildItem(0)),
              const SizedBox(width: 2),
              Expanded(child: buildItem(1)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: buildItem(2)),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    buildItem(3),
                    if (count > 4)
                      IgnorePointer(
                        child: Container(
                          color: Colors.black.withAlpha(110),
                          alignment: Alignment.center,
                          child: Text(
                            '+${count - 4}',
                            style: TextStyle(
                              color: context.ui.fontColorLight,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}