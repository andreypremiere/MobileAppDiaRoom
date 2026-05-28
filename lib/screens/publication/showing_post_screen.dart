import 'dart:async';
import 'package:dia_room/components/general/app_avatar.dart';
import 'package:dia_room/components/general/app_back_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/account_api.dart';
import '../../api/post_api.dart';
import '../../components/general/author_tile_appbar/author_error_tile.dart';
import '../../components/general/author_tile_appbar/author_loading_tile.dart';
import '../../components/general/author_tile_appbar/author_tile.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/showing_post/post_footer.dart';
import '../../components/showing_post/showing_canvas.dart';
import '../../api/auth_response.dart';
import '../../models/content_post/showing_post.dart';
import '../../models/post_view/author.dart';

class ShowingPostScreen extends StatefulWidget {
  final String postId;
  final String roomId;

  const ShowingPostScreen({super.key, required this.postId, required this.roomId});

  @override
  State<ShowingPostScreen> createState() => _ShowingPostScreenState();
}

class _ShowingPostScreenState extends State<ShowingPostScreen> {
  ShowingPost? _post;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _viewTimer;

  bool _isLoadingRoomInfo = false;
  Author? author;

  @override
  void initState() {
    super.initState();
    _loadPost();
    _loadRoomInfo();

    _viewTimer = Timer(
      const Duration(seconds: 3),
      () => sendView(postId: widget.postId),
    );
  }

  Future<void> _loadRoomInfo() async {
    if (_isLoadingRoomInfo) return;

    if (mounted) {
      setState(() {
        _isLoadingRoomInfo = true;
      });
    }

    try {
      final response = await getRoomInfoById(widget.roomId);

      if (!response.success) {
        return;
      }

      author = response.data['roomInfo'] as Author;
    } catch (e) {
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoomInfo = false;
        });
      }
    }
  }

  Future<void> _loadPost() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AuthResponse response = await getPost(widget.postId);

      if (response.success) {
        if (mounted) {
          setState(() {
            _post = response.data!['post'];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? "Не удалось загрузить публикацию";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Возникла ошибка в работе приложения. Пожалуйста, сообщите в поддержку.";
        });
      }
    }
  }

  @override
  void dispose() {
    _viewTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ui.viewingPostColor,
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: const AppBackButton(),
        centerTitle: false,
        title: _isLoadingRoomInfo
            ? AuthorShimmerTile()
            : author == null
            ? AuthorEmptyTile(onRetry: _loadRoomInfo)
            : AuthorTile(author: author!, onTap: () => context.push('/room/${author!.roomId}'),),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 1. Ошибка загрузки данных -> Экран ошибки с возможностью перезапуска через _loadPost
    if (!_isLoading && _errorMessage != null && _post == null) {
      return DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _loadPost,
      );
    }

    // 2. Идет первоначальная загрузка -> Полноэкранный лоадер
    if (_isLoading && _post == null) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // 3. Ситуация "Пост не найден" (если пришел пустой успешный ответ)
    if (!_isLoading && _post == null) {
      return Center(
        child: Text(
          "Публикация не найдена",
          style: TextStyle(color: context.ui.fontColorHint),
        ),
      );
    }

    // 4. Успешный сценарий -> Отрисовка холста с данными поста
    return ShowingCanvas(
      blocks: _post!.payload,
      footer: PostFooter(
        postId: widget.postId,
        authorRoomId: _post!.roomId,
        likesCount: _post!.stats.likes,
        viewsCount: _post!.stats.views,
        hashtags: _post!.hashtags,
        workshopLink: _post!.workshopLink,
      ),
    );
  }
}
