import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/post-v2/selectable_post_card.dart';
import 'package:dia_room/models/enums/post_v2/post_status.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../../utils/auth_service.dart';

class SelectPostV2 extends StatefulWidget {
  const SelectPostV2({super.key});

  @override
  State<SelectPostV2> createState() {
    return _StateSelectPostV2();
  }
}

class _StateSelectPostV2 extends State<SelectPostV2> {
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;          // Первая загрузка
  bool _isLoadMoreLoading = false;  // Подгрузка старых постов снизу
  bool _hasMore = true;             // Есть ли еще посты на сервере
  String? _errorMessage;
  List<PostResponse> _posts = [];
  late String roomId;

  int _page = 0;
  final int _limit = 10; // Твой лимит на страницу

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    final id = context.read<AuthProvider>().roomId;
    if (id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    } else {
      roomId = id;
      _loadPosts(isFirstLoad: true);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    // Если доскроллили почти до конца (за 200 пикселей) и загрузка не идет, грузим еще
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && !_isLoadMoreLoading && _hasMore) {
        _loadPosts(isFirstLoad: false);
      }
    }
  }

  Future<void> _loadPosts({required bool isFirstLoad}) async {
    if (!mounted) return;

    if (isFirstLoad) {
      setState(() {
        _page = 0;
        _hasMore = true;
        _isLoading = true;
        _errorMessage = null;
        _posts.clear();
      });
    } else {
      setState(() {
        _isLoadMoreLoading = true;
      });
    }

    try {
      final AuthResponse response = await getPostsByRoomId(
        targetRoomId: roomId,
        limit: _limit,
        page: _page,
      );

      if (!mounted) return;

      if (response.success) {
        final postsRoom = PostsRoom.fromMap(response.data as Map<String, dynamic>);
        final List<PostResponse> allPosts = postsRoom.posts;

        // Фильтруем публикации
        final filteredPosts = allPosts.where((post) {
          return post.status == PostStatus.published;
        }).toList();

        setState(() {
          _posts.addAll(filteredPosts);

          // Если сервер вернул меньше постов, чем наш лимит, значит дальше ничего нет
          if (allPosts.length < _limit) {
            _hasMore = false;
          } else {
            _page++; // Инкрементируем страницу для следующего запроса
          }

          _isLoading = false;
          _isLoadMoreLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = isFirstLoad ? (response.message ?? "Не удалось загрузить публикации") : null;
          _isLoading = false;
          _isLoadMoreLoading = false;
        });
        if (!isFirstLoad) {
          // Если упала пагинация, лучше показать тост или диалог, не ломая уже загруженное
          await AppInfoDialog.show(context, response.message ?? "Ошибка при подгрузке данных.");
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadMoreLoading = false;
        if (isFirstLoad) {
          _errorMessage = "Ошибка в работе приложения";
        }
      });
      await AppInfoDialog.show(context, "Ошибка во время работы приложения. Пожалуйста, обратитесь в поддержку.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: AppBackButton(),
        title: const Text(
          'Выберите пост',
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // СОСТОЯНИЕ ОШИБКИ (Только для первой загрузки)
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: () => _loadPosts(isFirstLoad: true),
        ),
      );
    }

    // СОСТОЯНИЕ ПЕРВОЙ ЗАГРУЗКИ
    if (_isLoading) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // ПУСТОЙ РЕЗУЛЬТАТ
    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Тут пусто.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // ОСНОВНОЙ КОНТЕНТ С КРУТИЛКОЙ ВНИЗУ
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            controller: _scrollController, // Привязали контроллер
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.80,
            ),
            itemCount: _posts.length,
            itemBuilder: (context, index) {
              final post = _posts[index];
              return SelectablePostCard(
                post: post,
                onTap: () => context.pop(post.id),
              );
            },
          ),
        ),

        // Индикатор подгрузки в самом низу экрана
        if (_isLoadMoreLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: DiaRoomLoader()),
          ),
      ],
    );
  }
}