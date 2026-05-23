import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../general/dialog_button.dart';

class AppDialogs {
  static Future<void> showEditDialog(
    BuildContext context, {
    required String title,
    required String currentValue,
    required Function(String) onSave,
    int? stroke = 1,
  }) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFFF8F8F8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'SNPro',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    minLines: 1,
                    maxLines: stroke,
                    controller: controller,
                    style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFB4B4B4),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      DialogButton(
                        text: "Отмена",
                        onPressed: () {
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                        textColor: context.ui.fontColorHint,
                        isTransparent: true,
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                      ),
                      const Spacer(),
                      DialogButton(
                        text: "Сохранить",
                        onPressed: () async {
                          await onSave(controller.text.trim());
                          if (context.mounted) Navigator.pop(context);
                        },
                        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10)
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
