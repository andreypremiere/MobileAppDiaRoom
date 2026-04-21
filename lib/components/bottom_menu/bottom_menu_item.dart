import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class BottomMenuItem extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const BottomMenuItem({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: context.ui.iconSizeBottomPanel,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}