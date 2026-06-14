import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/room_screen/app_dialogs.dart';
import 'package:dia_room/models/post_view/author.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/account_api.dart';
import '../../api/post_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/post_card/another_card.dart';
import '../../api/auth_response.dart';
import '../../components/post_card/own_card.dart';
import '../../utils/auth_service.dart';

// Твои новые компоненты для единообразия
import '../../components/general/author_tile_appbar/author_error_tile.dart';
import '../../components/general/author_tile_appbar/author_loading_tile.dart';
import '../../components/general/author_tile_appbar/author_tile.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';

class PersonalPostsScreen extends StatefulWidget {
  final String roomId;

  const PersonalPostsScreen({super.key, required this.roomId});

  @override
  State<PersonalPostsScreen> createState() => _StatePersonalPostsScreen();
}

class _StatePersonalPostsScreen extends State<PersonalPostsScreen> {
  // Состояния для постов
  List<dynamic> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Состояния для информации о комнате (если это не наша комната)
  Author? _author;
  bool _isLoadingRoomInfo = false;

  late bool _isMyRoom;

  @override
  void initState() {
    super.initState();

    // Проверяем, принадлежит ли комната текущему пользователю
    final myId = context.read<AuthProvider>().roomId;
    _isMyRoom = widget.roomId == myId;

    _loadPosts();

    if (!_isMyRoom) {
      _loadRoomInfo();
    }
  }

  /// Загрузка информации о чужой комнате для AppBar
  Future<void> _loadRoomInfo() async {
    if (_isLoadingRoomInfo) return;

    if (mounted) {
      setState(() {
        _isLoadingRoomInfo = true;
      });
    }

    try {
      final response = await getRoomInfoById(widget.roomId);

      if (response.success && mounted) {
        setState(() {
          _author = response.data!['roomInfo'] as Author;
        });
      }
    } catch (e) {
      // Игнорируем ошибку здесь, компонент AuthorEmptyTile покажет кнопку повтора
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoomInfo = false;
        });
      }
    }
  }

  /// Загрузка списка постов
  Future<void> _loadPosts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AuthResponse response = _isMyRoom
          ? await getOwnPosts()
          : await getRoomPosts(widget.roomId);

      if (response.success) {
        if (mounted) {
          setState(() {
            _posts = response.data!['listPosts'] ?? [];
            _isLoading = false;
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
    if (!_isMyRoom && _author == null) {
      _loadRoomInfo();
    }
    await _loadPosts();
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
        'Статьи',
      )
          : _isLoadingRoomInfo
          ? AuthorShimmerTile()
          : _author == null
          ? AuthorEmptyTile(onRetry: _loadRoomInfo)
          : AuthorTile(
        author: _author!),
      actions: _isMyRoom
          ? [
        IconButton(
          onPressed: () => context.push('/newPublicPost'),
          icon: const Icon(Icons.add_rounded, size: 34),
          color: context.ui.fontColorPrimary,
          // onPressed: () => context.push('/create_post_v2'),
          // icon: const Icon(Icons.add_rounded, size: 34),
          // color: context.ui.fontColorPrimary,
        ),
      ]
          : null,
    );
  }

  Widget _buildBody() {
    // 1. Ошибка загрузки постов
    if (!_isLoading && _errorMessage != null && _posts.isEmpty) {
      return DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _handleRefresh,
      );
    }

    // 2. Идет загрузка постов
    if (_isLoading && _posts.isEmpty) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // 3. Данные получены, но список пуст (с поддержкой pull-to-refresh)
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

    // 4. Успешный рендер списка постов
    return RefreshIndicator(
      color: context.ui.primaryColor,
      onRefresh: _handleRefresh,
      child: ListView.separated(
        // AlwaysScrollableScrollPhysics нужен, чтобы pull-to-refresh работал,
        // даже если постов мало и они не заполняют весь экран
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        itemCount: _posts.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index == _posts.length) {
            return SizedBox(height: MediaQuery.of(context).padding.bottom,);
          }

          final post = _posts[index];

          if (_isMyRoom) {
            return OwnPostComponent(
              post: post,
              onDelete: () async {
                final bool? confirm = await AppDialogs.showConfirmDialog(
                  context,
                  text: "Вы уверены, что хотите удалить пост?",
                  cancelText: "Отмена",
                  confirmText: "Удалить",
                );

                if (confirm == true) {
                  final result = await requestDeletePost(post.data.postId);

                  if (result.success) {
                    if (context.mounted) {
                      setState(() {
                        _posts.removeWhere((p) => p.data.postId == post.data.postId);
                      });
                    }
                  } else {
                    if (context.mounted) {
                      await AppInfoDialog.show(
                        context,
                        result.message ?? "Не удалось удалить пост.",
                      );
                    }
                  }
                }
              },
            );
          } else {
            return AnotherPostComponent(post: post);
          }
        },
      ),
    );
  }
}