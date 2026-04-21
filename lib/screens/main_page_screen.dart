import 'package:dia_room/components/bottom_menu/bottom_menu_item.dart';
import 'package:dia_room/components/keyboard_dismissible.dart';
import 'package:dia_room/models/auth_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../api/post_api.dart';
import '../components/bottom_menu_component.dart';
import '../components/post_component.dart';
import '../models/post_view/feed_post.dart';


class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() {
    return _StateMainPageScreen();
  }
}

class _StateMainPageScreen extends State<MainPageScreen> {
  String? avatarUrl;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  late Future<AuthResponse> _response;
  bool _isBottomMenuVisible = true;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false; // Видна ли кнопка "Вверх"

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      // Показывать кнопку, только если отскроллили вниз больше чем на 300 пикселей
      // и если мы сейчас скроллим вверх (используем направление)
      if (_scrollController.offset > 300 && !_showBackToTop && _isBottomMenuVisible) {
        setState(() => _showBackToTop = true);
      } else if ((_scrollController.offset <= 300 || !_isBottomMenuVisible) && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });

    _loadPosts();

    // Слушаем изменение фокуса, чтобы скрывать/показывать кнопку поиска
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    // Слушаем ввод текста для обновления состояния (например, для иконки очистки)
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Освобождение ресурсов контроллеров
    _scrollController.dispose(); // Не забываем освобождать ресурсы
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isBottomMenuVisible) {
        setState(() {
          _isBottomMenuVisible = false;
          _showBackToTop = false; // Прячем всё при движении вниз
        });
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isBottomMenuVisible) {
        setState(() => _isBottomMenuVisible = true);
      }
    }
    return true;
  }

  void _loadPosts() {
    setState(() {
      _response = getAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        extendBody: true,
        body: NotificationListener<UserScrollNotification>(
          onNotification: _handleScrollNotification,

          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // SliverAppBar был тут
          SliverSafeArea(
            top: true, // Сверху отступ даст SliverAppBar
            bottom: true, sliver: SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              sliver: FutureBuilder<AuthResponse>(
                future: _response,
                builder: (context, snapshot) {
                  // 1. СОСТОЯНИЕ ЗАГРУЗКИ
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF722323), // Твой фирменный цвет
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(child: Text("Ошибка сети: ${snapshot.error}")),
                    );
                  }

                  // 3. ПОЛУЧЕНИЕ ДАННЫХ
                  final authResponse = snapshot.data;

                  // Проверка на успех в твоем AuthResponse
                  if (authResponse == null || !authResponse.success) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(authResponse?.data?['error'] ?? "Ошибка загрузки"),
                      ),
                    );
                  }

                  final List<FeedPost> posts = authResponse.data?['listPosts'] ?? [];

                  if (posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("Лента пуста")),
                    );
                  }

                  // 4. ОТОБРАЖЕНИЕ СПИСКА
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        // if (index == posts.length) {
                        //   return SizedBox(height: MediaQuery.of(context).padding.bottom);
                        // }

                        final post = posts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PostComponent(
                            post: post,
                            // onTap: () {
                            //   // Здесь переделать просто передавать
                            //   context.push('/showPost', extra: post);
                            // },
                          ),
                        );
                      },
                      childCount: posts.length , // +1 для нижнего отступа
                    ),
                  );
                },
              ),
            ),)
          ],
        ),),

        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showBackToTop ? 1.0 : 0.0,
          child: Container(
              padding: EdgeInsets.all(2),
              // Стилизация контейнера: белый фон и скругление углов
              decoration: ShapeDecoration(
                color: context.ui.containerColor,
                shape: const StadiumBorder(), // Идеальное скругление сторон
                shadows: [ // В ShapeDecoration используется 'shadows', а не 'boxShadow'
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black.withAlpha(25),
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: BottomMenuItem(icon: Icons.arrow_upward_rounded, onPressed: _scrollToTop)
            ),
        ),

        bottomNavigationBar: AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: _isBottomMenuVisible ? Offset.zero : const Offset(0, 2), // Уезжает вниз
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isBottomMenuVisible ? 1.0 : 0.0,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 2,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [BottomMenu()],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
