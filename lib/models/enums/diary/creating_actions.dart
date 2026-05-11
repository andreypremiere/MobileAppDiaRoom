import 'package:flutter/material.dart';

enum CreatingDiaryAction {
  video("Видео", Icons.video_camera_back_outlined),
  photo("Фотографии", Icons.photo_library_outlined),
  audioNote("Аудиосообщение", Icons.mic_none_rounded),
  videoNote("Видеосообщение", Icons.video_call_outlined);

  final String label;
  final IconData icon;
  const CreatingDiaryAction(this.label, this.icon);
}