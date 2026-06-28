import 'package:dia_room/api/post_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/contracts/global_search/responses/found_rooms.dart';
import 'package:dia_room/contracts/posts/responses/found_posts.dart';
import 'package:dia_room/models/enums/global_search/global_search_method.dart';
import 'package:dia_room/models/post_view/feed_post.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../components/general/app_back_button.dart';
import '../api/account_api.dart';
import '../api/post_v2_api.dart';
import '../components/global_search_screen/room_tile.dart';
import '../components/loading_widget/error_widget.dart';
import '../components/loading_widget/loader_widget.dart';
import '../components/post-v2/card.dart';
import '../components/post_card/feed_card.dart';
import '../contracts/posts_v2/responses/post_response.dart';
import '../models/global_search/room_info.dart';

class GlobalSearchScreen extends StatefulWidget {
  final String? text;
  final GlobalSearchMethod? method;

  const GlobalSearchScreen({
    super.key,
    this.text,
    this.method,
  });

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<dynamic> _foundValues = [];
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  GlobalSearchMethod _currentMethod = GlobalSearchMethod.room;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    if (widget.method != null) {
      _currentMethod = widget.method!;
    }

    if (widget.text != null) {
      _searchController.text = widget.text!;
    }

    if (_searchController.text.isNotEmpty) {
      _searchValues();
    }

  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _fetchSearch();
      }
    }
  }

  void onTapMethod(GlobalSearchMethod method) {
    if (mounted) {
      setState(() {
        _currentMethod = method;
      });
    } else {
      return;
    }
    _searchValues();
  }

  Widget _buttonMethod(GlobalSearchMethod method) {
    return ElevatedButton(
      onPressed: () {
        onTapMethod(method);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: method == _currentMethod
            ? context.ui.primaryColor
            : context.ui.containerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),

          side: method == _currentMethod
              ? BorderSide.none
              : BorderSide(color: context.ui.primaryColor, width: 2),
        ),

        elevation: 0,
      ),
      child: Text(
        method.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: method != _currentMethod
              ? context.ui.primaryColor
              : context.ui.containerColor,
        ),
      ),
    );
  }

  Widget _panelButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 36,
          minHeight: 0,
        ),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: GlobalSearchMethod.values.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _buttonMethod(GlobalSearchMethod.values[index]);
          },
        ),
      ),
    );
  }

  Future<void> _fetchSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      int incomingLength = 0;

      switch (_currentMethod) {
        case GlobalSearchMethod.room:
          final response = await searchRooms(
            page: _currentPage,
            limit: _limit,
            value: _searchController.text.trim(),
          );

          if (!mounted) return;

          if (!response.success) {
            setState(() {
              _errorMessage = response.message ?? "Не удалось выполнить поиск комнат.";
            });
            return;
          }

          final FoundRooms foundRooms = FoundRooms.fromMap(response.data);
          incomingLength = foundRooms.rooms.length;

          setState(() {
            _foundValues.addAll(foundRooms.rooms);
          });
          break;

        case GlobalSearchMethod.post:
          final response = await searchPosts(
            page: _currentPage,
            limit: _limit,
            value: _searchController.text.trim(),
          );

          if (!mounted) return;

          if (!response.success) {
            setState(() {
              _errorMessage = response.message ?? "Не выполнить поиск публикаций.";
            });
            return;
          }

          final FoundPosts foundPosts = FoundPosts.fromMap(response.data);
          incomingLength = foundPosts.posts.length;

          setState(() {
            _foundValues.addAll(foundPosts.posts);
          });
          break;

        case (GlobalSearchMethod.postV2):
          final response = await searchPostsV2(
            page: _currentPage,
            limit: _limit,
            value: _searchController.text.trim(),
          );

          if (!mounted) return;

          if (!response.success) {
            setState(() {
              _errorMessage = response.message ?? "Не выполнить поиск публикаций.";
            });
            return;
          }

          final PostsRoom foundPosts = PostsRoom.fromMap(response.data);
          incomingLength = foundPosts.posts.length;

          setState(() {
            _foundValues.addAll(foundPosts.posts);
          });
          break;
      }

      if (mounted) {
        setState(() {
          _currentPage++;
          if (incomingLength < _limit) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = "Ошибка в работе приложения";
        await AppInfoDialog.show(context, "Ошибка в работе приложения. Пожалуйста, сообщите в поддержку.");
        return;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearText() {
    if (mounted) {
      setState(() {
        _searchController.clear();
        _foundValues.clear();
        _errorMessage = null;
        _currentPage = 0;
        _hasMore = true;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _searchValues() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _hasMore = true;
        _currentPage = 0;
        _foundValues.clear();
      });
    }
    _fetchSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        centerTitle: false,
        leading: const AppBackButton(),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 46,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: switch (_currentMethod) {
                      GlobalSearchMethod.room => 'id или никнейм',
                      GlobalSearchMethod.post => 'Название статьи',
                      GlobalSearchMethod
                          .postV2 => 'Название хештега',
                    },
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearText,
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: _searchValues,
              icon: Icon(
                Icons.search,
                size: context.ui.iconSizePanel,
                color: context.ui.iconColorPrimary,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _panelButtons(),
          _buildBody()
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isLoading) {
      return Expanded(
        child: Center(
          child: DiaRoomErrorView(
            errorMessage: _errorMessage!,
            onRefresh: _searchValues,
          ),
        ),
      );
    }

    if (_isLoading && _foundValues.isEmpty) {
      return const Expanded(
        child: Center(
          child: DiaRoomLoader(),
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return const Expanded(
        child: SizedBox.shrink(),
      );
    }

    if (!_isLoading && _foundValues.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Ничего не найдено",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        controller: _scrollController,
        separatorBuilder: (context, index) => const SizedBox(height: 6),
        itemCount: _foundValues.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _foundValues.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: DiaRoomLoader(),
              ),
            );
          }

          switch (_currentMethod) {
            case GlobalSearchMethod.room:
              return RoomTile(room: _foundValues[index] as RoomInfo);
            case GlobalSearchMethod.post:
              return FeedPostComponent(post: _foundValues[index] as FeedPost);
            case GlobalSearchMethod.postV2:
              return PostCard(
                post: _foundValues[index] as PostResponse,
              );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
