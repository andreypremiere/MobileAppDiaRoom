import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AppBarButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const AppBarButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        backgroundColor: backgroundColor ?? context.ui.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? context.ui.fontColorLight,
        ),
      ),
    );
  }
}