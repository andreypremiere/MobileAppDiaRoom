import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../api/post_api.dart';
import '../components/showing_post/slider_block.dart';
import '../components/showing_post/video_preview_widget.dart';
import '../models/auth_response.dart';
import '../models/content_post/content_post.dart';
import '../models/enums/post_types.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_text.dart';
import '../models/post_creator/block_video.dart';
import '../utils/utils.dart';


class ShowingPostScreen extends StatefulWidget {
  final String postId;

  const ShowingPostScreen({super.key, required this.postId});

  @override
  State<ShowingPostScreen> createState() => _ShowingPostScreenState();
}

class _ShowingPostScreenState extends State<ShowingPostScreen> {
  late Future<AuthResponse> _postFuture;

  @override
  void initState() {
    super.initState();
    // Запускаем загрузку поста при открытии экрана
    _postFuture = getPost(widget.postId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthResponse>(
      future: _postFuture,
      builder: (context, snapshot) {
        // 1. Состояние загрузки
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: context.ui.viewingPostColor,
            body: Center(child: CircularProgressIndicator(color: context.ui.primaryColor)),
          );
        }

        // 2. Обработка ошибки запроса
        if (snapshot.hasError || (snapshot.hasData && !snapshot.data!.success)) {
          final errorMsg = snapshot.data?.data?['error'] ?? snapshot.error.toString();
          print(errorMsg);
          return Scaffold(
            backgroundColor: context.ui.viewingPostColor,
            appBar: AppBar(backgroundColor: context.ui.appBarColor),
            body: Center(child: Text('Ошибка: $errorMsg')),
          );
        }

        // 3. Успешная загрузка, достаем пост
        final ShowingPost post = snapshot.data!.data!['post'];

        return Scaffold(
          backgroundColor: context.ui.viewingPostColor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: AppBar(
              backgroundColor: context.ui.appBarColor,
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_rounded,
                    size: context.ui.iconSizePanel),
                color: context.ui.fontColorPrimary,
              ),
              titleSpacing: 0, // Убираем лишний отступ слева
              // Кликабельный виджет автора в AppBar
              title: GestureDetector(
                onTap: () {
                  // Переход в профиль комнаты по roomId
                  print('Переход в профиль: ${post.roomId}');
                  // context.push('/room/${post.roomId}');
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Аватар автора
                    CachedNetworkImage(
                      imageUrl: post.author.avatar,
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 18,
                        backgroundImage: imageProvider,
                      ),
                      placeholder: (context, url) => CircleAvatar(
                        radius: 18,
                        backgroundColor: context.ui.primaryColor,
                      ),
                      errorWidget: (context, url, error) => CircleAvatar(
                        radius: 18,
                        backgroundColor: context.ui.primaryColor,
                        child: Icon(Icons.person, color: Colors.white, size: 20),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Никнейм автора
                    Text(
                      post.author.roomName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.ui.fontColorPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Иконка функций, здесь будет, поделиться, пожаловаться, не интересует
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.more_horiz, color: context.ui.fontColorPrimary, size: context.ui.iconSizePanel),
                ),
              ],
            ),
          ),

          // Отрисовка самого холста (payload)
          body: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            itemCount: post.payload.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final BlockPost block = post.payload[index]; // Теперь это объект типа BlockPost

              // Проверяем тип объекта через runtime type или поле type (enum)
              switch (block.type) {
                case BlockType.text:
                  return _buildTextBlock(block as TextBlockPost);
                case BlockType.photos:
                  return _buildPhotosBlock(block as BlockPhotos);
                case BlockType.videos:
                  return VideoPreviewWidget(block: block as BlockVideo,);
                default:
                  return const SizedBox.shrink();
              }
            },
          ),
        );
      },
    );
  }

  // ===========================================================================
  // РЕНДЕР БЛОКОВ
  // ===========================================================================

  /// Рендерит текстовый блок
  Widget _buildTextBlock(TextBlockPost block) {

    return Text(
      block.value,
      style: TextStyle(
        fontSize: block.textType.size,
        fontWeight: block.textType.weight,
        color: const Color(0xFF333333),
        fontFamily: 'SNPro',
      ),
    );
  }

  /// Рендерит блок фотографий
  Widget _buildPhotosBlock(BlockPhotos block) {
    final List<PhotoInfo> listPhoto = block.listPhoto;
    if (listPhoto.isEmpty) return const SizedBox.shrink();

    // Достаем URL-адреса из массива объектов
    final List<String> urls = listPhoto.map((e) => getFullUrl(e.publicUrl)).toList();

    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: block.methodView == MethodViewPhoto.slider
            ? PhotoSlider(
          urls: urls,
          onTap: (index) => _openGalleryPreview(urls, index),
        )
            : _buildPhotoTiles(urls),
      ),
    );
  }

  void _openGalleryPreview(List<String> urls, int startIndex) {
    context.push('/full_image_screen', extra: {
      'urls': urls,
      'index': startIndex,
    });
  }

  Widget _buildClickableNetworkImageForTiles(String url, List<String> currentBlockUrls, int index) {
    return GestureDetector(
      onTap: () => _openGalleryPreview(currentBlockUrls, index), // Передаем список и индекс
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // ... placeholder, errorWidget (твои стандартные)
      ),
    );
  }

  Widget _buildPhotoTiles(List<String> urls) {
    int count = urls.length;

    if (count == 1) return _buildClickableNetworkImageForTiles(urls[0], urls, 0); // <--- Обновили

    if (count == 2) {
      return Row(
        children: [
          Expanded(child: _buildClickableNetworkImageForTiles(urls[0], urls, 0)), // <--- Обновили
          const SizedBox(width: 2),
          Expanded(child: _buildClickableNetworkImageForTiles(urls[1], urls, 1)), // <--- Обновили
        ],
      );
    }

    if (count == 3) {
      return Row(
        children: [
          Expanded(child: _buildClickableNetworkImageForTiles(urls[0], urls, 0)), // <--- Обновили
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _buildClickableNetworkImageForTiles(urls[1], urls, 1)), // <--- Обновили
                const SizedBox(height: 2),
                Expanded(child: _buildClickableNetworkImageForTiles(urls[2], urls, 2)), // <--- Обновили
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
              Expanded(child: _buildClickableNetworkImageForTiles(urls[0], urls, 0)), // <--- Обновили
              const SizedBox(width: 2),
              Expanded(child: _buildClickableNetworkImageForTiles(urls[1], urls, 1)), // <--- Обновили
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildClickableNetworkImageForTiles(urls[2], urls, 2)),
              const SizedBox(width: 2),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Сама 4-я картинка, которая тоже кликабельна и ведет в галерею
                    _buildClickableNetworkImageForTiles(urls[3], urls, 3),

                    // Если фото больше 4, накладываем затемнение и счетчик
                    if (count > 4)
                      IgnorePointer( // Чтобы нажатие уходило на картинку ниже
                        child: Container(
                          color: Colors.black.withAlpha(110), // Затемнение
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

  /// Универсальный виджет для сетевой картинки холста с кешированием
  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Container(
        color: const Color(0xFFF5F5F5),
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      errorWidget: (context, url, error) => Container(
        color: const Color(0xFFE0E0E0),
        child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
      ),
    );
  }

  // /// Рендерит видео-блок
  // void _openFullScreenVideo(String videoUrl) {
  //   context.push('/full_screen_video', extra: videoUrl);
  // }

  // Widget _buildVideoBlock(BlockVideo block) {
  //   final String previewUrl = _getFullUrl(block.previewPublicUrl);
  //   final String videoUrl = _getFullUrl(block.publicUrl);
  //
  //   return GestureDetector(
  //     onTap: () => _openFullScreenVideo(videoUrl),
  //     child: AspectRatio(
  //       aspectRatio: 1,
  //       child: ClipRRect(
  //         borderRadius: BorderRadius.circular(12),
  //         child: Stack(
  //           fit: StackFit.expand,
  //           children: [
  //             _buildNetworkImage(previewUrl),
  //             Container(color: Colors.black.withAlpha(100)),
  //             const Center(
  //               child: Icon(
  //                 Icons.play_circle_fill,
  //                 color: Colors.white,
  //                 size: 64,
  //               ),
  //             ),
  //             Positioned(
  //               bottom: 12,
  //               right: 12,
  //               child: Container(
  //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                 decoration: BoxDecoration(
  //                   color: Colors.black.withAlpha(150),
  //                   borderRadius: BorderRadius.circular(6),
  //                 ),
  //                 child: Text(
  //                   block.getFormattedDuration(),
  //                   style: const TextStyle(
  //                     color: Colors.white,
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w600,
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}