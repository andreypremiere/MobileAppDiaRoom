import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/room_screen/app_dialogs.dart';
import 'package:dia_room/models/enums/post_v2/action_post.dart';
import 'package:dia_room/models/post_view/author.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/account_api.dart';
import '../../api/post_v2_api.dart';
import '../../components/post-v2/card_manage.dart';
import '../../contracts/posts_v2/responses/post_response.dart';

import '../../components/general/app_back_button.dart';
import '../../utils/auth_service.dart';

import '../../components/general/author_tile_appbar/author_error_tile.dart';
import '../../components/general/author_tile_appbar/author_loading_tile.dart';
import '../../components/general/author_tile_appbar/author_tile.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';

class PersonalPostsScreenV2 extends StatefulWidget {
  final String roomId;

  const PersonalPostsScreenV2({super.key, required this.roomId});

  @override
  State<PersonalPostsScreenV2> createState() => _StatePersonalPostsScreen();
}

class _StatePersonalPostsScreen extends State<PersonalPostsScreenV2> {
  // Использованием типизированный список под новые модели
  List<PostResponse> _posts = [];

  // Состояния пагинации (как на главной ленте)
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  Author? _author;
  bool _isLoadingRoomInfo = false;
  late bool _isMyRoom;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final myId = context.read<AuthProvider>().roomId;
    _isMyRoom = widget.roomId == myId;

    // Слушатель скролла для ленивой загрузки новых страниц
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchPosts();
      }
    });

    _fetchPosts();

    if (!_isMyRoom) {
      _loadRoomInfo();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> processAction(ActionPost action, PostResponse post) async {
    switch (action) {
      case ActionPost.delete:
        final resultConfirm = await AppDialogs.showConfirmDialog(context, text: "Вы уверены, что хотите удалить пост безвозвратно?", cancelText: "Отмена", confirmText: "Удалить");
        if (resultConfirm == null || resultConfirm == false) {
          return;
        }

        final result = await deletePost(postId: post.id);
        if (result.success) {
          if (mounted) {
            setState(() {
              _posts.removeWhere((el) => el.id == post.id);
            });
          }
        } else {
          if (mounted) {
            await AppInfoDialog.show(context, result.message ?? "Не удалось удалить пост");
          }
        }
    }
  }

  Future<void> _handleCreatePost() async {
    // 1. Ожидаем результат с экрана создания поста
    final result = await context.push('/create_post_v2');

    // 2. Проверяем, что вернулся именно объект нового поста и виджет еще в дереве
    if (result != null && result is PostResponse && mounted) {
      setState(() {
        // 3. Вставляем новый пост на самую первую позицию (индекс 0)
        _posts.insert(0, result);
      });

      // Опционально: если список был прокручен вниз, можно плавно вернуть пользователя наверх,
      // чтобы он сразу увидел свою новую публикацию
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  /// Загрузка информации о чужой комнате для AppBar
  Future<void> _loadRoomInfo() async {
    if (_isLoadingRoomInfo) return;

    setState(() {
      _isLoadingRoomInfo = true;
    });

    try {
      final response = await getRoomInfoById(widget.roomId);

      if (response.success && mounted) {
        setState(() {
          _author = response.data!['roomInfo'] as Author;
        });
      }
    } catch (e) {
      // Ошибка обрабатывается компонентом AuthorEmptyTile
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoomInfo = false;
        });
      }
    }
  }

  /// Загрузка списка постов с пагинацией (Новый метод API)
  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      // Вызываем переделанный метод getPostsByRoomId
      final response = await getPostsByRoomId(
        targetRoomId: widget.roomId,
        limit: _limit,
        page: _currentPage,
      );

      if (response.success) {
        // Маппим данные через твой кастомный PostsRoom, как в общей ленте
        final postsRoom = PostsRoom.fromMap(response.data as Map<String, dynamic>);
        final List<PostResponse> newPosts = postsRoom.posts;

        if (mounted) {
          setState(() {
            _posts.addAll(newPosts);
            _currentPage++;
            _isLoading = false;
            if (newPosts.length < _limit) {
              _hasMore = false;
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? "Не удалось загрузить публикации";
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

  /// Обновление по свайпу (pull-to-refresh)
  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() {
        _posts = [];
        _currentPage = 0;
        _hasMore = true;
      });
    }
    if (!_isMyRoom && _author == null) {
      _loadRoomInfo();
    }
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.ui.appBarColor,
      leading: const AppBackButton(),
      centerTitle: false,
      title: _isMyRoom
          ? Text(
        'Публикации',
      )
          : _isLoadingRoomInfo
          ? const AuthorShimmerTile()
          : _author == null
          ? AuthorEmptyTile(onRetry: _loadRoomInfo)
          : AuthorTile(author: _author!, onTap: () {}),
      actions: _isMyRoom
          ? [
        IconButton(
          onPressed: _handleCreatePost,
          icon: const Icon(Icons.add_rounded, size: 34),
          color: context.ui.fontColorPrimary,
        ),
      ]
          : null,
    );
  }

  Widget _buildBody() {
    // 1. Ошибка загрузки постов (когда список пуст)
    if (!_isLoading && _errorMessage != null && _posts.isEmpty) {
      return DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _handleRefresh,
      );
    }

    // 2. Первая загрузка постов
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // 3. Данные получены, но у пользователя нет публикаций
    if (!_isLoading && _posts.isEmpty) {
      return RefreshIndicator(
        color: context.ui.primaryColor,
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Постов пока нет',
                  style: TextStyle(color: context.ui.fontColorHint),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Успешный рендер персональной ленты постов
    return RefreshIndicator(
      color: context.ui.primaryColor,
      onRefresh: _handleRefresh,
      child: ListView.separated(
        controller: _scrollController, // Привязали контроллер для пагинации
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
        itemCount: _posts.length + 1, // +1 для нижнего лоадера пагинации или отступа
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Если дошли до самого низа списка
          if (index == _posts.length) {
            if (_isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: DiaRoomLoader()),
              );
            }
            return SizedBox(height: MediaQuery.of(context).padding.bottom);
          }

          final post = _posts[index];

          // Теперь вместо Own/Another используем универсальный PostCard
          // Если внутри карточки понадобится контекстное меню удаления для автора поста,
          // его будет проще прокинуть через callback или проверять внутри самой карточки.
          return PostManageCard(
            post: post,
            isMyPost: _isMyRoom, processAction: processAction,
          );
        },
      ),
    );
  }
}