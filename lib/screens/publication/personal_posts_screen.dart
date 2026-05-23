import 'package:dia_room/components/general/app_avatar.dart';
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

// PersonalPostsScreen отображает список постов конкретной комнаты
class PersonalPostsScreen extends StatefulWidget {
  final String roomId;

  const PersonalPostsScreen({super.key, required this.roomId});

  @override
  State<PersonalPostsScreen> createState() {
    return _StatePersonalPostsScreen();
  }
}

class _StatePersonalPostsScreen extends State<PersonalPostsScreen> {
  late Future<AuthResponse> _postsFuture;
  late Future<AuthResponse> _roomInfoFuture;
  bool isMyRoom = false;

  @override
  void initState() {
    super.initState();

    // Проверяем, принадлежит ли комната текущему пользователю
    final myId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myId;

    if (!isMyRoom) {
      _roomInfoFuture = getRoomInfoById(widget.roomId);
    }
    if (isMyRoom) {
      _postsFuture = getOwnPosts();
    } else {
      _postsFuture = getRoomPosts(widget.roomId);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() {
      if (isMyRoom) {
        _postsFuture = getOwnPosts();
      } else {
        _postsFuture = getRoomPosts(widget.roomId);
        _roomInfoFuture = getRoomInfoById(widget.roomId);
      }
    });

    await _postsFuture;
  }

  // Вспомогательный виджет для  загрузки
  Widget _buildSkeletonItem({required double width, required double height, double radius = 8}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Скелет для аватара
        _buildSkeletonItem(width: 36, height: 36, radius: 18),
        const SizedBox(width: 10),
        // Скелет для имени
        _buildSkeletonItem(width: 100, height: 20, radius: 4),
      ],
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.ui.containerColor,
        title: Text('Удаление', style: TextStyle(color: context.ui.fontColorPrimary),),
        content: Text('Вы уверены, что хотите удалить этот пост?', style: TextStyle(color: context.ui.fontColorPrimary),),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Отмена', style: TextStyle(color: context.ui.fontColorPrimary),)),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Удалить', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: AppBackButton(),
          title: isMyRoom
              ? Text(
            'Публикации',
            style: TextStyle(
              color: context.ui.fontColorPrimary,
              fontFamily: 'SNPro',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          )
              : FutureBuilder<AuthResponse>(
            future: _roomInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerTitle();
              }

              if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.success) {
                return const SizedBox.shrink();
              }

              // Данные загружены
              final roomInfo = snapshot.data!.data!['roomInfo'] as Author;

              return InkWell(
                onTap: () => context.push('/room/${widget.roomId}'),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAvatar(avatarPath: roomInfo.avatar, radius: 18,),
                      const SizedBox(width: 10),
                      Text(
                        roomInfo.roomName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.ui.fontColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: isMyRoom ? [
            // IconButton(
            //   onPressed: () => print('Переход в черновики'),
            //   icon: const Icon(Icons.folder_copy_outlined, size: 28),
            //   color: context.ui.fontColorPrimary,
            // ),
            IconButton(
              onPressed: () => context.push('/newPublicPost'),
              icon: const Icon(Icons.add_rounded, size: 34),
              color: context.ui.fontColorPrimary,
            ),
          ] : null,
        ),),
        // Прокручиваемая колонка с постами
        body: RefreshIndicator(
          color: context.ui.primaryColor,
          onRefresh: _handleRefresh,
          child: FutureBuilder<AuthResponse>(
          future: _postsFuture,
          builder: (context, snapshot) {
            // 1. Состояние ожидания
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. Обработка ошибок
            if (snapshot.hasError || (snapshot.hasData && !snapshot.data!.success)) {
              return Center(child: Text('Ошибка загрузки: ${snapshot.error}'));
            }

            // 3. Данные получены
            final List posts = snapshot.data!.data!['listPosts'] ?? [];

            if (posts.isEmpty) {
              return const Center(child: Text('Постов пока нет'));
            }

            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              itemCount: posts.length,
              // Отступы между карточками (твои spacing: 10)
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final post = posts[index];

                if (isMyRoom) {
                  return OwnPostComponent(post: post, onDelete: () async {
                    final bool? confirm = await _showDeleteDialog(context);

                    if (confirm == true) {
                      final result = await requestDeletePost(post.data.postId);

                      if (result.success) {
                        _handleRefresh();
                      }
                    }
                  },);
                } else {
                  return AnotherPostComponent(post: post);
                }
              },
            );
          },
        ),),
      ),
    );
  }
}
