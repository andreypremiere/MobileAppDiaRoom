import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class FullWidthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  const FullWidthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.height,
    this.padding,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height ?? 48,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          minimumSize: Size.zero,
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
          backgroundColor:
          backgroundColor ?? context.ui.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.ui.radiusButtonStandard,
            ),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor ?? context.ui.fontColorLight,
          ),
        ),
      ),
    );
  }
}