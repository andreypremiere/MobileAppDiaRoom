import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/room_screen/author_tile.dart';
import '../../models/post_view/author.dart';

class RoomListScreen extends StatefulWidget {
  final String title;
  final Future<AuthResponse> Function(int page, int limit) loadAction;

  const RoomListScreen({
    super.key,
    required this.title,
    required this.loadAction,
  });

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  final List<Author> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  final int _limit = 20;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await widget.loadAction(_page, _limit);

      if (response.success) {
        final List<dynamic> rawAuthors = response.data?['authors'] ?? [];

        final List<Author> newUsers = rawAuthors
            .map((item) => Author.fromMap(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _page++;
          _users.addAll(newUsers);
          if (newUsers.length < _limit) _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки списка (${widget.title}): $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded, size: context.ui.iconSizePanel),
          color: context.ui.fontColorPrimary,
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: context.ui.fontColorPrimary,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _users.clear();
            _page = 1;
            _hasMore = true;
          });
          await _loadMore();
        },
        child: _users.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: _users.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _users.length) {
              return AuthorListTile(author: _users[index]);
            } else {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}