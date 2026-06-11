import 'package:flutter/material.dart';

enum ActionPost {
  delete('Удалить', Icons.delete_outline, Colors.redAccent);

  final String name;
  final IconData icon;
  final Color color;

  const ActionPost( this.name, this.icon, this.color);
}