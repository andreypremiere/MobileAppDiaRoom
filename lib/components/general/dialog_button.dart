import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class DialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  /// Если true — кнопка будет прозрачной, а текст окрасится в [textColor]
  final bool isTransparent;

  /// Кастомный цвет текста/иконки (используется всегда в прозрачном режиме,
  /// либо если нужно перекрасить текст в стандартном)
  final Color? textColor;

  /// Кастомный фоновый цвет для стандартного режима
  final Color? backgroundColor;

  const DialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isTransparent = false,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Определяем фоновый цвет в зависимости от режима
    final effectiveBackgroundColor = isTransparent
        ? Colors.transparent
        : (backgroundColor ?? context.ui.primaryColor);

    // Определяем цвет текста:
    // В прозрачном режиме приоритет у переданного textColor, иначе берем primaryColor.
    // В обычном режиме приоритет у переданного textColor, иначе белый.
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        // Убираем тень и эффекты Material, если кнопка прозрачная
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