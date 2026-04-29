import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/components/showing_post/text_block_widget.dart';
import 'package:dia_room/configuration/urls.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../api/post_api.dart';
import '../../components/showing_post/photos_block_widget.dart';
import '../../components/showing_post/post_footer.dart';
import '../../components/showing_post/showing_canvas.dart';
import '../../components/showing_post/slider_block.dart';
import '../../components/showing_post/video_preview_widget.dart';
import '../../api/auth_response.dart';
import '../../models/content_post/showing_post.dart';
import '../../models/enums/block_type.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_text.dart';
import '../../models/post_creator/block_video.dart';
import '../../utils/utils.dart';

class ShowingPostScreen extends StatefulWidget {
  final String postId;

  const ShowingPostScreen({super.key, required this.postId});

  @override
  State<ShowingPostScreen> createState() => _ShowingPostScreenState();
}

class _ShowingPostScreenState extends State<ShowingPostScreen> {
  late Future<AuthResponse> _postFuture;
  Timer? _viewTimer;

  @override
  void initState() {
    super.initState();
    // Запускаем загрузку поста при открытии экрана
    _postFuture = getPost(widget.postId);
    _viewTimer = Timer(
      const Duration(seconds: 4),
      () => sendView(postId: widget.postId),
    );
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
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
            body: Center(
              child: CircularProgressIndicator(color: context.ui.primaryColor),
            ),
          );
        }

        // 2. Обработка ошибки запроса
        if (snapshot.hasError ||
            (snapshot.hasData && !snapshot.data!.success)) {
          final errorMsg =
              snapshot.data?.data?['error'] ?? snapshot.error.toString();
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
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.ui.iconSizePanel,
                ),
                color: context.ui.fontColorPrimary,
              ),
              // Кликабельный виджет автора в AppBar
              // Внутри AppBar title:
              title: InkWell(
                onTap: () {
                  context.push('/room/${post.roomId}');
                },
                borderRadius: BorderRadius.circular(12),
                // Скругляем область клика
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
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
                          child: const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 20,
                          ),
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
              ),
              actions: [
                // Иконка функций, здесь будет, поделиться, пожаловаться, не интересует
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.more_horiz,
                    color: context.ui.fontColorPrimary,
                    size: context.ui.iconSizePanel,
                  ),
                ),
              ],
            ),
          ),

          body: ShowingCanvas(
            blocks: post.payload,
            // Внедряем панель опционально
            footer: PostFooter(
              postId: widget.postId,
              authorRoomId: post.roomId,
              likesCount: post.stats.likes,
              viewsCount: post.stats.views,
              hashtags: post.hashtags,
            ),
          ),
        );
      },
    );
  }
}
