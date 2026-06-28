import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class CommentInputPanel extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const CommentInputPanel({
    super.key,
    required this.controller,
    required this.onSend,
    this.isSending = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 4,
        top: 6,
        bottom: 6 + MediaQuery.of(context).viewInsets.bottom, // Защита от перекрытия клавиатурой
      ),
      // decoration: BoxDecoration(
      //   // color: context.ui.containerColor,
      //   border: Border(
      //     top: BorderSide(
      //       color: context.ui.fontColorHint.withOpacity(0.1),
      //       width: 1,
      //     ),
      //   ),
      // ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          decoration: BoxDecoration(
            color: context.ui.containerColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
              )
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: 4,
                  minLines: 1,
                  style: TextStyle(color: context.ui.fontColorPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.transparent,
                    hintText: "Оставить комментарий...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: controller,
                builder: (context, child) {
                  final hasContent = controller.text.trim().isNotEmpty;
                  return IconButton(
                    onPressed: (isSending || !hasContent) ? null : onSend,
                    icon: isSending
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : Icon(
                      Icons.send_rounded,
                      color: hasContent ? context.ui.primaryColor : context.ui.iconColorPrimary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}