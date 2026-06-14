import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/auth_response.dart';
import '../../api/post_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../models/post_view/personal_post.dart';
import '../../utils/auth_service.dart';
import '../../components/diary/compact_post_card.dart';

class SelectPostDiary extends StatefulWidget {

  const SelectPostDiary({super.key});

  @override
  State<SelectPostDiary> createState() {
    return _StateSelectPostDiary();
  }
}

class _StateSelectPostDiary extends State<SelectPostDiary> {
  bool _isLoading = false;
  String? _errorMessage;
  List<PersonalPost> _posts = [];
  late String roomId;

  @override
  void initState() {
    super.initState();
    final id = context.read<AuthProvider>().roomId;
    if (id == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.pop();
      });
    } else {
      roomId = id;
      _loadPosts(); // Запускаем загрузку, если roomId на месте
    }
  }

  Future<void> _loadPosts() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthResponse response = await getOwnPosts();

      if (!mounted) return;

      if (response.success) {
        final List<PersonalPost> allPosts = response.data?['listPosts'] as List<PersonalPost>;

        final filteredPosts = allPosts.where((post) {
          return post.status == 'published' && post.statusAi == 'passed';
        }).toList();

        setState(() {
          _posts = filteredPosts;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? "Не удалось загрузить публикации";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _errorMessage = "Ошибка в работе приложения";
      await AppInfoDialog.show(context, "Ошибка во время работы приложения. Пожалуйста, обратитесь в поддержку.");
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
        ),
      ),
      // Прокручиваемая колонка с постами
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    // СОСТОЯНИЕ ОШИБКИ
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _loadPosts,
        ),
      );
    }

    // СОСТОЯНИЕ ЗАГРУЗКИ
    if (_isLoading) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // ПУСТОЙ РЕЗУЛЬТАТ (После фильтрации ничего не подошло или постов реально нет)
    if (_posts.isEmpty) {
      return const Center(
        child: Text(
          'Тут пусто.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // ОСНОВНОЙ КОНТЕНТ (Сетка с отфильтрованными карточками публикаций)
    return GridView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        final post = _posts[index];

        return CompactPostCard(
          post: post,
          onTap: () {
            context.pop(post.data.postId);
          },
        );
      },
    );
  }
}