import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../models/enums/post_types.dart';
import '../models/post_creator/block_text.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../models/post_creator/post_draft.dart';
import '../utils/utils.dart';

/// Экран предварительного просмотра публикации.
/// Отображает блоки контента в том виде, в котором их увидит конечный пользователь.
class PostPreviewScreen extends StatelessWidget {
  final PostDraft postDraft;

  const PostPreviewScreen({super.key, required this.postDraft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: const Color(0xFFB4B4B4),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: SvgPicture.asset(
              'assets/icons/button_back.svg',
              width: 32,
              height: 32,
            ),
          ),
          title: const Text(
            'Предпросмотр',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'SNPro',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                context.push('/set_settings');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                backgroundColor: const Color(0xFFC9C9C9),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Далее',
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: postDraft.blocks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final block = postDraft.blocks[index];

          if (block is BlockTextCreating) {
            return _buildTextBlock(block);
          } else if (block is BlockPhotosCreating) {
            return _buildPhotosBlock(block);
          } else if (block is BlockVideoCreating) {
            return _buildVideoBlock(block);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  /// Рендерит текстовый блок с учетом стилей (размер, вес) из метаданных
  Widget _buildTextBlock(BlockTextCreating block) {
    return Text(
      block.controller.text,
      style: TextStyle(
        fontSize: block.textType.size,
        fontWeight: block.textType.weight,
        color: const Color(0xFF333333),
        fontFamily: 'SNPro',
      ),
    );
  }

  /// Рендерит блок фотографий, выбирая между слайдером или сеткой (плиткой)
  Widget _buildPhotosBlock(BlockPhotosCreating block) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: block.methodView == MethodViewPhoto.slider
            ? _buildPhotoSlider(block.paths)
            : _buildPhotoTiles(block.paths),
      ),
    );
  }

  /// Создает горизонтальный слайдер для просмотра фотографий
  Widget _buildPhotoSlider(List<String> paths) {
    return PageView.builder(
      itemCount: paths.length,
      itemBuilder: (context, index) {
        return Image.file(
          File(paths[index]),
          fit: BoxFit.cover,
        );
      },
    );
  }

  /// Создает адаптивную сетку для фотографий в зависимости от их количества (от 1 до 4+)
  Widget _buildPhotoTiles(List<String> paths) {
    int count = paths.length;

    Widget img(String path) => Image.file(File(path), fit: BoxFit.cover, width: double.infinity, height: double.infinity);

    if (count == 1) return img(paths[0]);

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: img(paths[0])),
          const SizedBox(width: 2),
          Expanded(child: img(paths[1])),
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(child: img(paths[0])),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: img(paths[1])),
                const SizedBox(height: 2),
                Expanded(child: img(paths[2])),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: img(paths[0])),
              const SizedBox(width: 2),
              Expanded(child: img(paths[1])),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: img(paths[2])),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    img(paths[3]),
                    if (count > 4)
                      Container(
                        color: Colors.black.withAlpha(50),
                        alignment: Alignment.center,
                        child: Text(
                          '+${count - 4}',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Рендерит видео-блок в виде интерактивного превью с длительностью и иконкой воспроизведения
  Widget _buildVideoBlock(BlockVideoCreating block) {
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(block.previewPath!),
              fit: BoxFit.cover,
            ),
            Container(color: Colors.black.withAlpha(100)),
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(70),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  block.getformattedDuration(block.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}