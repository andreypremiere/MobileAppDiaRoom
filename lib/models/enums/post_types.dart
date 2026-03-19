import 'package:flutter/material.dart';

enum BlockPostType {
  text,
  photos,
  videos,
  audio,
  file
}

extension BlockPostTypeExtension on BlockPostType {
  String get label {
    switch (this) {
      case BlockPostType.text: return 'Текст';
      case BlockPostType.photos: return 'Фотографии';
      case BlockPostType.videos: return 'Видео';
      case BlockPostType.audio: return 'Аудио';
      case BlockPostType.file: return 'Файл';
    }
  }

  IconData get icon {
    switch (this) {
      case BlockPostType.text: return Icons.text_fields;
      case BlockPostType.photos: return Icons.photo;
      case BlockPostType.videos: return Icons.videocam;
      case BlockPostType.audio: return Icons.audiotrack;
      case BlockPostType.file: return Icons.description;
    }
  }
}

enum TextType {
  header('Заголовок'),
  subtitle('Подзаголовок'),
  text('Текст');

  final String label;

  const TextType(this.label);
}

enum MethodViewPhoto {
  tiles('Плитки'),
  slider('Слайдер');

  final String label;

  const MethodViewPhoto(this.label);
}