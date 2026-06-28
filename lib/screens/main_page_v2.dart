import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import '../api/post_v2_api.dart';
import '../components/post-v2/card.dart';
import '../components/general/keyboard_dismissible.dart';
import '../components/loading_widget/error_widget.dart';
import '../components/loading_widget/loader_widget.dart';
import '../components/main_page_screen/bottom_menu/bottom_menu_component.dart';
import '../components/main_page_screen/bottom_menu/bottom_menu_item.dart';
import '../components/post-v2/pinterest_post_card.dart';
import '../contracts/posts_v2/responses/post_response.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MainPageScreenV2 extends StatefulWidget {
  const MainPageScreenV2({super.key});

  @override
  State<MainPageScreenV2> createState() {
    return _StateMainPageScreen();
  }
}

class _StateMainPageScreen extends State<MainPageScreenV2> {
  List<PostResponse> _posts = [];
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  String? _errorMessage;
  bool _isPinterestView = false;

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
        if (mounted) {
          setState(() => _showBackToTop = true);
        }
      } else if ((_scrollController.offset <= 300 || !_isBottomMenuVisible) &&
          _showBackToTop) {
        if (mounted) {
          setState(() => _showBackToTop = false);
        }
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

  Future<void> _navigateToPost(PostResponse post) async {
    final updatedPost = await context.push<PostResponse>(
      '/post_v2/${post.id}',
      extra: post,
    );

    if (updatedPost != null && mounted) {
      setState(() {
        final index = _posts.indexWhere((p) => p.id == post.id);
        if (index != -1) {
          _posts[index] = updatedPost;
        }
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  bool _handleScrollNotification(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      if (_isBottomMenuVisible) {
        if (mounted) {
          setState(() {
            _isBottomMenuVisible = false;
            _showBackToTop = false;
          });
        }
      }
    } else if (notification.direction == ScrollDirection.forward) {
      if (!_isBottomMenuVisible) {
        if (mounted) {
          setState(() => _isBottomMenuVisible = true);
        }
      }
    }
    return true;
  }

  Future<void> _fetchPosts() async {
    if (_isLoading || !_hasMore) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await getGlobalFeed(page: _currentPage, limit: _limit);

      if (response.success) {
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
            _errorMessage = response.message ?? "Ошибка загрузки";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Ошибка в работе приложения. Пожалуйста, обратитесь в поддержку.";
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    if (mounted) {
      setState(() {
        _posts = [];
        _currentPage = 0;
        _hasMore = true;
      });
    }
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
                SliverAppBar(
                  backgroundColor: context.ui.appBarColor,
                  floating: false,
                  title: Text(
                    'Главная',
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        _isPinterestView ? Icons.view_agenda_outlined : Icons.grid_view_outlined,
                        color: context.ui.iconColorPrimary,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPinterestView = !_isPinterestView;
                        });
                      },
                    ),
                  ],
                ),
                SliverSafeArea(
                  top: false,
                  sliver: SliverPadding(
                    padding: const EdgeInsets.only(
                      top: 8,
                      left: 0,
                      right: 0,
                      bottom: 0
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
                        : _isPinterestView
                        ? SliverMasonryGrid.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childCount: _posts.length,
                      itemBuilder: (context, index) {
                        return PinterestPostCard(post: _posts[index], onTap: () => _navigateToPost(_posts[index]));
                      },
                    )
                        : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PostCard(post: _posts[index]),
                        );
                      }, childCount: _posts.length),
                    ),
                  ),
                ),

                if (_isLoading && _posts.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: DiaRoomLoader(
                          color: context.ui.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        floatingActionButton: Visibility(
          visible: _showBackToTop,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _showBackToTop ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.all(2),
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
        ),

        bottomNavigationBar: AnimatedSlide(
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