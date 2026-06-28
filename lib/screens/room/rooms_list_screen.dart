import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
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
  String? _errorMessage;
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

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AuthResponse response = await widget.loadAction(_page, _limit);

      if (response.success) {
        final List<dynamic> rawAuthors = response.data?['authors'] ?? [];

        final List<Author> newUsers = rawAuthors
            .map((item) => Author.fromMap(item as Map<String, dynamic>))
            .toList();

        if (mounted) {
          setState(() {
            _page++;
            _users.addAll(newUsers);
            _isLoading = false;
            if (newUsers.length < _limit) _hasMore = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? "Не удалось получить список комнат";
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
        _users.clear();
        _page = 1;
        _hasMore = true;
      });
    }
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: AppBackButton(),
        title: Text(
          widget.title
        ),
      ),
      body: _buildBody()
    );
  }

  Widget _buildBody() {
    if (!_isLoading && _errorMessage != null && _users.isEmpty) {
      return DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _onRefresh,
      );
    }

    if (_isLoading && _users.isEmpty) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    if (!_isLoading && _users.isEmpty) {
      return Center(
        child: Text(
          _errorMessage ?? "Тут пусто.",
          style: TextStyle(color: context.ui.fontColorHint),
        ),
      );
    }

    return RefreshIndicator(
      color: context.ui.primaryColor,
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 10),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _users.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index < _users.length) {
            return AuthorListTile(author: _users[index]);
          } else {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: _isLoading
                    ? DiaRoomLoader()
                    : const SizedBox.shrink(),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}