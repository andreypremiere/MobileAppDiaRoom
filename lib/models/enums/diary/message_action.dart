import 'package:flutter/material.dart';

enum MessageAction {
  copy("Копировать", Icons.copy),
  delete("Удалить", Icons.delete_outline);

  final String label;
  final IconData icon;
  const MessageAction(this.label, this.icon);
}