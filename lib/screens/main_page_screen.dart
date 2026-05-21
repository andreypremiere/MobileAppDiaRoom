import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../api/post_api.dart';
import '../components/general/keyboard_dismissible.dart';
import '../components/loading_widget/error_widget.dart';
import '../components/loading_widget/loader_widget.dart';
import '../components/main_page_screen/bottom_menu/bottom_menu_component.dart';
import '../components/main_page_screen/bottom_menu/bottom_menu_item.dart';
import '../components/post_card/feed_card.dart';
import '../models/post_view/feed_post.dart';

class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() {
    return _StateMainPageScreen();
  }
}

class _StateMainPageScreen extends State<MainPageScreen> {
  List<FeedPost> _posts = [];
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;

  // late Future<AuthResponse> _response;
  bool _isBottomMenuVisible = true;
  final ScrollController _scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.offset > 300 &&
          !_showBackToTop &&
          _isBottomMenuVisible) {
        setState(() => _showBackToTop = true);
      } else if ((_scrollController.offset <= 300 || !_isBottomMenuVisible) &&
          _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _fetchPosts();
      }
    });

    _fetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
          _showBackToTop = false;
        });
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isBottomMenuVisible) {
        setState(() => _isBottomMenuVisible = true);
      }
    }
    return true;
  }

  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getAllPosts(page: _currentPage, limit: _limit);

      if (response.success) {
        final List<FeedPost> newPosts = response.data?['listPosts'] ?? [];

        setState(() {
          _posts.addAll(newPosts);
          _currentPage++;
          _isLoading = false;
          if (newPosts.length < _limit) {
            _hasMore = false;
          }
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = response.data?['error'] ?? "Ошибка загрузки";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Ошибка сети";
      });
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _posts = [];
      _currentPage = 0;
      _hasMore = true;
    });
    await _fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: Scaffold(
        extendBody: true,
        body: !_isLoading && _errorMessage != null
            ? DiaRoomErrorView(
                errorMessage: _errorMessage!,
                onRefresh: () {
                  _onRefresh();
                },
              )
            : RefreshIndicator(
                color: context.ui.primaryColor,
                onRefresh: _onRefresh,
                child: NotificationListener<UserScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      // Основной список постов
                      SliverSafeArea(
                        top: true,
                        sliver: SliverPadding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                          sliver: _posts.isEmpty && _isLoading
                              ? const SliverFillRemaining(
                                  child: Center(child: DiaRoomLoader()),
                                )
                              : _posts.isEmpty && !_isLoading
                              ? SliverFillRemaining(
                                  child: Center(
                                    child: Text(_errorMessage ?? "Лента пуста"),
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: FeedPostComponent(
                                        post: _posts[index],
                                      ),
                                    );
                                  }, childCount: _posts.length),
                                ),
                        ),
                      ),

                      // Индикатор загрузки в самом низу (футер)
                      if (_isLoading && _posts.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.ui.primaryColor,
                              ),
                            ),
                          ),
                        ),

                      // // Отступ снизу, чтобы контент не перекрывался меню
                      // SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.bottom + 2)),
                    ],
                  ),
                ),
              ),

        // Стрелка вверх
        floatingActionButton: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: _showBackToTop ? 1.0 : 0.0,
          child: Container(
            padding: EdgeInsets.all(2),
            decoration: ShapeDecoration(
              color: context.ui.containerColor,
              shape: const StadiumBorder(),
              shadows: [
                BoxShadow(
                  blurRadius: 8,
                  color: Colors.black.withAlpha(25),
                  spreadRadius: 4,
                ),
              ],
            ),
            child: BottomMenuItem(
              icon: Icons.arrow_upward_rounded,
              onPressed: _scrollToTop,
            ),
          ),
        ),

        // Нижнее меню
        bottomNavigationBar: (!_isLoading && _errorMessage != null) || (_isLoading) ? null : AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          offset: _isBottomMenuVisible ? Offset.zero : const Offset(0, 2),
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
