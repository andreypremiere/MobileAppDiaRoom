import 'package:flutter/material.dart';

enum CreatingWorkshopAction {
  folder("Каталог", Icons.create_new_folder_outlined),
  photo("Фото", Icons.photo),
  video("Видео", Icons.video_call);

  final String label;
  final IconData icon;

  const CreatingWorkshopAction(this.label, this.icon);
}