import 'package:flutter/material.dart';

import '../../api/post_api.dart';
import '../../screens/rooms_list_screen.dart';

class LikeButton extends StatefulWidget {
  final String postId;
  final int initialCount;

  const LikeButton({super.key, required this.postId, required this.initialCount});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  late int _count;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _count = widget.initialCount;
    _initStatus();
  }

  Future<void> _initStatus() async {
    final status = await getLikeStatus(widget.postId);
    if (mounted) {
      setState(() {
        _isLiked = status;
        _isLoading = false;
      });
    }
  }

  void _handleLike() async {
    setState(() {
      _isLiked = !_isLiked;
      _isLiked ? _count++ : _count--;
    });

    final res = await toggleLike(widget.postId, _isLiked);
    if (!res.success) {
      print("Ошибка лайка: ${res.message}");
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _isLiked ? _count++ : _count--;
        });
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(_isLiked),
              color: _isLiked ? Colors.red : Colors.grey,
            ),
          ),
          onPressed: _isLoading ? null : _handleLike,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RoomListScreen(
                  title: 'Понравилось',
                  loadAction: (page, limit) => requestGetLikers(
                    postId: widget.postId,
                    page: page,
                    limit: limit,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 8.0, top: 4.0, bottom: 4.0, left: 8),
            child: Text(
                '$_count',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                )
            ),
          ),
        ),
      ],
    );
  }
}