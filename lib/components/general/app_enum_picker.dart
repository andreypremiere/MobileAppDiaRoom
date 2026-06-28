import 'package:dia_room/components/general/dialog_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/enums/dialog_abstract_class.dart';

class AppEnumPicker<T extends HasLabel> extends StatelessWidget {
  final List<T> values;
  final String cancelText;

  const AppEnumPicker({
    super.key,
    required this.values,
    this.cancelText = "Отмена",
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.ui.containerColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),

            ...values.map((item) => InkWell(
              onTap: () => Navigator.pop(context, item),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: context.ui.fontColorPrimary,
                    fontFamily: 'SNPro',
                  ),
                ),
              ),
            )),

            const SizedBox(height: 16),

            Align(
              alignment: Alignment.centerLeft,
              child: DialogButton(text: "Отмена", onPressed: () {
                if (context.mounted) {
                  context.pop();
                }
              }, isTransparent: true, textColor: context.ui.fontColorHint,),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}