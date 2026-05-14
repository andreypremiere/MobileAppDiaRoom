import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/auth_response.dart';
import '../../api/post_api.dart';
import '../../components/general/app_back_button.dart';
import '../../models/post_view/personal_post.dart';
import '../../utils/auth_service.dart';
import 'compact_post_card.dart';

class SelectPostDiary extends StatefulWidget {

  const SelectPostDiary({super.key});

  @override
  State<SelectPostDiary> createState() {
    return _StateSelectPostDiary();
  }
}

class _StateSelectPostDiary extends State<SelectPostDiary> {
  late Future<AuthResponse> _postsFuture;
  late String roomId;

  @override
  void initState() {
    super.initState();
    _postsFuture = getOwnPosts();
    final id = context.read<AuthProvider>().roomId;
    if (id == null) {
      context.pop();
    } else {
      roomId = id;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: AppBackButton(),
        title: Text(
          'Выберите публикацию',
          style: TextStyle(
            color: context.ui.fontColorPrimary,
            fontFamily: 'SNPro',
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Прокручиваемая колонка с постами
      body: FutureBuilder<AuthResponse>(
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
          final List<PersonalPost> rawPosts = snapshot.data!.data!['listPosts'] ?? [];

          final List<PersonalPost> posts = rawPosts.where((post) => post.status == 'published' && post.statusAi == "passed").toList();

          if (posts.isEmpty) {
            return const Center(child: Text('Постов пока нет'));
          }

          return GridView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            // Настройка сетки
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.95,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              return CompactPostCard(
                post: post,
                onTap: () {
                  context.pop(post.data.postId);
                },
              );
            },
          );
        },
      ),
    );
  }
}