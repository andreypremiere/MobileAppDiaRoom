import 'package:dia_room/models/auth_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/account_api.dart';
import '../components/room_screen/author_tile.dart';
import '../models/post_view/author.dart';

class FollowersScreen extends StatefulWidget {
  final String roomId;
  const FollowersScreen({super.key, required this.roomId});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<Author> _authors = [];
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
      final AuthResponse response = await requestGetFollowers(
          roomId: widget.roomId,
          page: _page,
          limit: _limit
      );

      if (response.success) {
        // 1. Получаем сырой список (dynamic)
        final List<dynamic> rawAuthors = response.data?['authors'] ?? [];

        // 2. Превращаем его в список объектов Author
        final List<Author> newAuthors = rawAuthors
            .map((item) => Author.fromMap(item as Map<String, dynamic>))
            .toList();

        setState(() {
          _page++;
          _authors.addAll(newAuthors);
          if (newAuthors.length < _limit) _hasMore = false;
        });
      }
    } catch (e) {
      debugPrint("Ошибка загрузки подписчиков: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_rounded, size: context.ui.iconSizePanel),
          color: context.ui.fontColorPrimary,
        ),
        title: Text(
          'Подписчики',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: context.ui.fontColorPrimary),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _authors.clear();
            _page = 1;
            _hasMore = true;
          });
          await _loadMore();
        },
        child: _authors.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 10),
          itemCount: _authors.length + (_hasMore ? 1 : 0),
          separatorBuilder: (context, index) => const Divider(height: 1, indent: 70),
          itemBuilder: (context, index) {
            if (index < _authors.length) {
              return AuthorListTile(author: _authors[index]);
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