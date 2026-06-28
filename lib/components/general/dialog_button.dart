import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isTransparent;
  final Color? textColor;
  final Color? backgroundColor;

  final EdgeInsets padding;

  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isTransparent = false,
    this.textColor,
    this.backgroundColor,
    this.padding = const EdgeInsets.symmetric(vertical: 10, horizontal: 24)
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = isTransparent
        ? Colors.transparent
        : (backgroundColor ?? context.ui.primaryColor);

    final effectiveForegroundColor = isTransparent
        ? (textColor ?? context.ui.primaryColor)
        : (textColor ?? Colors.white);

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveBackgroundColor,
        foregroundColor: effectiveForegroundColor,
        elevation: 0,
        minimumSize: Size.zero,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        shadowColor: isTransparent ? Colors.transparent : null,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}