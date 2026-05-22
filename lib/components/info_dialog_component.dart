import 'package:dia_room/components/general/dialog_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AppInfoDialog extends StatelessWidget {
  final String message;
  final String buttonText;

  const AppInfoDialog({
    super.key,
    required this.message,
    this.buttonText = 'Ок',
  });

  static Future<void> show(BuildContext context, String text) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AppInfoDialog(message: text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: context.ui.containerColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Окно подстраивается под контент
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: context.ui.fontColorPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            DialogButton(text: buttonText, onPressed: () => Navigator.of(context).pop())
          ],
        ),
      ),
    );
  }
}