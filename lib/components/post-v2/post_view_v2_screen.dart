import 'package:dia_room/components/general/app_back_button.dart';
import 'package:flutter/material.dart';
import 'package:dia_room/utils/app_theme.dart';
import '../../api/post_v2_api.dart';
import '../../contracts/posts_v2/responses/post_response.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/post-v2/card.dart';

class PostViewScreen extends StatefulWidget {
  final String postId;
  final PostResponse? post;

  const PostViewScreen({
    super.key,
    required this.postId,
    this.post,
  });

  @override
  State<PostViewScreen> createState() => _PostViewScreenState();
}

class _PostViewScreenState extends State<PostViewScreen> {
  PostResponse? _post;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _post = widget.post;
      _isLoading = false;
    } else {
      _loadPost();
    }
  }

  Future<void> _loadPost() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await getPostById(postId: widget.postId);

      if (response.success && response.data != null) {
        if (mounted) {
          setState(() {
            _post = PostResponse.fromMap(response.data as Map<String, dynamic>);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _errorMessage = response.message ?? "Не удалось загрузить публикацию";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Произошла ошибка при загрузке. Попробуйте позже.";
        });
      }
    }
  }

  void _handleBack(BuildContext context) {
    final navigator = Navigator.of(context);

    if (navigator.canPop()) {
      navigator.pop(_post);
    } else {
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          _handleBack(context);
        },
        child: Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: AppBackButton(onPressed: () => _handleBack(context)),
      ),
      body: _isLoading
          ? const Center(child: DiaRoomLoader())
          : _errorMessage != null
          ? DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _loadPost,
      )
          : _post == null
          ? Center(child: Text("Публикация не найдена", style: TextStyle(color: context.ui.fontColorPrimary)))
          : RefreshIndicator(
        color: context.ui.primaryColor,
        onRefresh: _loadPost,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: PostCard(post: _post!),
          ),
        ),
      ),
    ));
  }
}