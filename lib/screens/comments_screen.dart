import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/auth_response.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/info_dialog_component.dart';
import '../../utils/app_theme.dart';
import '../components/general/comments/comment_card.dart';
import '../components/general/comments/input_panel.dart';
import '../models/i_comment_item.dart';

class CommentsScreen<T extends ICommentItem> extends StatefulWidget {
  final String targetId; // Это может быть либо postId, либо messageId

  // Передаем функцию запроса из нужного API
  final Future<AuthResponse> Function({required String id, required int page, required int limit}) onLoadCommentsApi;

  // Передаем функцию отправки из нужного API
  final Future<AuthResponse> Function({required String id, required String text}) onSendCommentApi;

  // Функция-маппер, которая знает, как превратить Map из базы в конкретный CommentResponse
  final T Function(Map<String, dynamic> map) fromMap;

  const CommentsScreen({
    super.key,
    required this.targetId,
    required this.onLoadCommentsApi,
    required this.onSendCommentApi,
    required this.fromMap,
  });

  @override
  State<CommentsScreen<T>> createState() => _CommentsScreenState<T>();
}

class _CommentsScreenState<T extends ICommentItem> extends State<CommentsScreen<T>> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();

  final List<T> _comments = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _limit = 10;
  String? _errorMessage;
  int _commentsAddedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadComments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadComments();
    }
  }

  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      // Вызываем переданный через конструктор API метод
      final AuthResponse response = await widget.onLoadCommentsApi(
        id: widget.targetId,
        page: _currentPage,
        limit: _limit,
      );

      if (!response.success) {
        setState(() {
          _errorMessage = response.message ?? "Не удалось загрузить комментарии";
        });
        return;
      }

      final List<dynamic> rawComments = response.data['comments'] ?? [];

      // Парсим с помощью динамического маппера widget.fromMap
      final List<T> fetchedComments = rawComments
          .map((c) => widget.fromMap(c as Map<String, dynamic>))
          .toList();

      setState(() {
        _currentPage++;
        final uniqueFetchedComments = fetchedComments.where((fetched) =>
        !_comments.any((existing) => existing.id == fetched.id)
        ).toList();

        _comments.addAll(uniqueFetchedComments);

        if (fetchedComments.length < _limit) _hasMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Ошибка сетевого соединения";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      // Вызываем переданный через конструктор API метод для создания
      final AuthResponse response = await widget.onSendCommentApi(
        id: widget.targetId,
        text: text,
      );

      if (response.success) {
        final newComment = widget.fromMap(response.data);
        setState(() {
          _comments.add(newComment);
          _commentsAddedCount++;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      } else {
        if (mounted) {
          AppInfoDialog.show(context, response.message ?? "Не удалось отправить комментарий.");
        }
      }
    } catch (e) {
      if (mounted) {
        AppInfoDialog.show(context, "Ошибка при публикации. Проверьте подключение к сети.");
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _onRefresh() {
    setState(() {
      _hasMore = true;
      _currentPage = 0;
      _comments.clear();
      _errorMessage = null;
    });
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          context.pop(_commentsAddedCount);
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: context.ui.appBarColor,
            leading: AppBackButton(onPressed: () => context.pop(_commentsAddedCount)),
            title: Text(
              "Комментарии",
              style: TextStyle(color: context.ui.fontColorPrimary),
            ),
          ),
          body: Column(
            children: [
              Expanded(child: _buildMainContent()),
              CommentInputPanel(
                controller: _commentController,
                onSend: _sendComment,
                isSending: _isSending,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_errorMessage != null && _comments.isEmpty) {
      return Center(
        child: DiaRoomErrorView(errorMessage: _errorMessage!, onRefresh: _onRefresh),
      );
    }

    if (_isLoading && _comments.isEmpty) {
      return const Center(child: DiaRoomLoader());
    }

    if (_comments.isEmpty) {
      return RefreshIndicator(
        color: context.ui.primaryColor,
        onRefresh: () async => _onRefresh(),
        child: const CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              child: Center(
                child: Text(
                  "Комментариев пока нет.\nБудьте первым!",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: context.ui.primaryColor,
      onRefresh: () async => _onRefresh(),
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _comments.length + (_hasMore ? 1 : 0),
        separatorBuilder: (context, index) => Divider(
          color: context.ui.fontColorHint.withOpacity(0.05),
          height: 1,
          indent: 64,
        ),
        itemBuilder: (context, index) {
          if (index == _comments.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: DiaRoomLoader()),
            );
          }

          return CommentCard(
            comment: _comments[index],
            onLongPress: () {},
          );
        },
      ),
    );
  }
}