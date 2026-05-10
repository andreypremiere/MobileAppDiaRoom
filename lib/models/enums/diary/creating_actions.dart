import 'package:flutter/material.dart';

enum CreatingDiaryAction {
  media("Медиа", Icons.photo_library_outlined),
  audio("Аудиосообщение", Icons.mic_none_rounded),
  video("Видеосообщение", Icons.video_camera_back_outlined);

  final String label;
  final IconData icon;
  const CreatingDiaryAction(this.label, this.icon);
}