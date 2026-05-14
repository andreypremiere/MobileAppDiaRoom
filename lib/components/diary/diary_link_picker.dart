import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../models/enums/diary/link_objects.dart';

class DiaryLinkPicker extends StatelessWidget {
  const DiaryLinkPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.ui.containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Теперь это будет работать для детей
          children: [
            const SizedBox(height: 8),

            // Список вариантов
            ...LinkAction.values.map((action) => InkWell(
              onTap: () => Navigator.pop(context, action),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity, // Чтобы кликалась вся ширина
                padding: const EdgeInsets.symmetric(vertical: 12), // Регулируй отступ между пунктами здесь
                child: Text(
                  action.label,
                  textAlign: TextAlign.center, // Центрируем сам текст
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.ui.fontColorPrimary,
                  ),
                ),
              ),
            )),

            const SizedBox(height: 16), // Отступ перед кнопкой отмена

            // Кнопка Отмена слева снизу
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  minimumSize: const Size(60, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  "Отмена",
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}