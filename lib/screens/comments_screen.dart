import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../api/auth_response.dart';
import '../../api/post_v2_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/info_dialog_component.dart';
import '../../utils/app_theme.dart';
import '../../utils/auth_service.dart';
import '../components/general/comments/comment_card.dart';
import '../components/general/comments/input_panel.dart';
import '../contracts/posts_v2/responses/comment_response.dart';


class PostCommentsScreen extends StatefulWidget {
  final String postId;

  const PostCommentsScreen({super.key, required this.postId});

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _commentController = TextEditingController();

  List<CommentResponse> _comments = [];
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

  /// Получение комментариев с пагинацией
  Future<void> _loadComments() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final AuthResponse response = await getComments(
        postId: widget.postId,
        page: _currentPage,
        limit: _limit,
      );

      if (!response.success) {
        setState(() {
          _errorMessage = response.message ?? "Не удалось загрузить комментарии";
        });
        return;
      }

      // Предполагаем, что бэкенд возвращает список в поле 'comments'
      final List<dynamic> rawComments = response.data['comments'] ?? [];
      final List<CommentResponse> fetchedComments = rawComments
          .map((c) => CommentResponse.fromMap(c as Map<String, dynamic>))
          .toList();

      setState(() {
        _currentPage++;
        final uniqueFetchedComments = fetchedComments.where((fetched) =>
        !_comments.any((existing) => existing.id == fetched.id)
        ).toList();

        // Добавляем в список только уникальные
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

  /// Отправка комментария
  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    _commentController.clear();
    FocusScope.of(context).unfocus();

    try {
      final AuthResponse response = await createComment(
        postId: widget.postId,
        text: text,
      );

      if (response.success) {
        final newComment = CommentResponse.fromMap(response.data);
        setState(() {
          // Вставляем новый комментарий в конец списка или в начало (в зависимости от желаемой сортировки)
          _comments.add(newComment);
          _commentsAddedCount++;
        });

        // Автоматически прокручиваем список вниз к новому комментарию
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
            style: TextStyle(
              color: context.ui.fontColorPrimary,
            ),
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
      )),
    );
  }

  Widget _buildMainContent() {
    // 1. Состояние ошибки
    if (_errorMessage != null && _comments.isEmpty) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _onRefresh,
        ),
      );
    }

    // 2. Первоначальный лоадер
    if (_isLoading && _comments.isEmpty) {
      return const Center(child: DiaRoomLoader());
    }

    // 3. Пустой список комментариев
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

    // 4. Отображение списка комментариев
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
          indent: 64, // Делаем отступ разделителя, чтобы он начинался под текстом
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
            onLongPress: () {
            },
          );
        },
      ),
    );
  }
}