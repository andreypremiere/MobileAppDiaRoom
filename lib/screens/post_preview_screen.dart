import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../models/enums/post_types.dart';
import '../models/post_creator/block_post.dart';
import '../models/post_creator/block_text.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../utils/utils.dart';

class PostPreviewScreen extends StatelessWidget {
  final List<BlockPost> blocks;

  const PostPreviewScreen({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    // Фильтруем пустые текстовые блоки и блоки без медиа, чтобы не было пустых дыр
    final validBlocks = blocks.where((block) {
      if (block is BlockText) return block.controller.text.trim().isNotEmpty;
      if (block is BlockPhotos) return block.paths.isNotEmpty;
      if (block is BlockVideo) return block.path != null && block.previewPath != null;
      return false;
    }).toList();

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
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: validBlocks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12), // Отступ между блоками
        itemBuilder: (context, index) {
          final block = validBlocks[index];

          if (block is BlockText) {
            return _buildTextBlock(block);
          } else if (block is BlockPhotos) {
            return _buildPhotosBlock(block);
          } else if (block is BlockVideo) {
            return _buildVideoBlock(block);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- Рендер Текста ---
  Widget _buildTextBlock(BlockText block) {
    // Здесь в будущем можно добавить стили (жирный, курсив, заголовки) в зависимости от block.textType
    return Text(
      block.controller.text,
      style: TextStyle(
        fontSize: block.metadata['size']?.toDouble() ?? 16,
        fontWeight: getFontWeight(block.metadata['weight'] ?? 0),
        color: Color(0xFF333333),
        fontFamily: 'SNPro',
      ),
    );
  }

  // --- Рендер Фото (Квадрат: Плитка или Слайдер) ---
  Widget _buildPhotosBlock(BlockPhotos block) {
    return AspectRatio(
      aspectRatio: 1, // Жесткий квадрат
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: block.methodView == MethodViewPhoto.slider
            ? _buildPhotoSlider(block.paths)
            : _buildPhotoTiles(block.paths),
      ),
    );
  }

  // Слайдер (PageView)
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

  // Плитка (Умная сетка)
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

    // 4 и более (рендерим первые 4 в виде 2x2)
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
                    if (count > 4) // Если фото больше 4, показываем +N поверх последнего
                      Container(
                        color: Colors.black.withOpacity(0.5),
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

  // --- Рендер Видео (Квадрат с превью) ---
  Widget _buildVideoBlock(BlockVideo block) {
    return AspectRatio(
      aspectRatio: 1, // Делаем квадратным
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // 1. Само превью (картинка)
            Image.file(
              File(block.previewPath!),
              fit: BoxFit.cover,
            ),

            // 2. Затемнение для читаемости элементов
            Container(color: Colors.black.withOpacity(0.1)),

            // 3. Значок Play по центру
            const Center(
              child: Icon(
                Icons.play_circle_fill,
                color: Colors.white,
                size: 64,
              ),
            ),

            // 4. Длительность в правом нижнем углу
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
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