import 'package:dia_room/api/auth_response.dart';
import 'package:flutter/material.dart';
import 'package:dia_room/utils/app_theme.dart';

import '../../api/account_api.dart';


class FollowButton extends StatefulWidget {
  final String roomId;

  const FollowButton({super.key, required this.roomId});

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  bool? _isFollowed; // null пока идет загрузка
  bool _isLoading = false; // для обработки нажатия

  @override
  void initState() {
    super.initState();
    _checkFollowStatus();
  }

  // Метод инициализации состояния с сервера
  Future<void> _checkFollowStatus() async {
    final result = await checkSubscription(widget.roomId);
    print(result);
    if (result.success) {
      if (mounted) {
        setState(() {
          _isFollowed = result.data!['result'];
        });
      }
    }

  }

  // Метод переключения подписки
  Future<void> _toggleFollow() async {
    setState(() => _isLoading = true);

    try {
      final AuthResponse result;
      if (_isFollowed!) {
        result = await unfollowRoom(widget.roomId);
      } else {
        result = await followRoom(widget.roomId);
      }

      if (result.success) {
        setState(() {
          _isFollowed = !_isFollowed!;
        });
      }
    } catch (e) {
      setState(() {
        _isFollowed = false;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFollowed == null) {
      return const SizedBox(
        width: 100,
        height: 36,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    // Стили зависят от состояния подписки
    final bool followed = _isFollowed!;
    final Color bgColor = followed ? context.ui.containerColor : context.ui.primaryColor;
    final Color textColor = followed ? context.ui.primaryColor : context.ui.fontColorLight;
    final String label = followed ? 'Отписаться' : 'Подписаться';

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        key: ValueKey(followed),
        height: 38,
        child: OutlinedButton(
          onPressed: _isLoading ? null : _toggleFollow,
          style: OutlinedButton.styleFrom(
            backgroundColor: bgColor,
            foregroundColor: textColor,
            side: followed ? BorderSide(color: context.ui.primaryColor) : BorderSide.none,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.ui.radiusButtonStandard),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: _isLoading
              ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: textColor))
              : Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ),
    );
  }
}