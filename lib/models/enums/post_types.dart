import 'package:flutter/material.dart';

enum BlockType {
  text('Текст', 'text', Icons.text_fields),
  photos('Фотографии', 'photos', Icons.photo),
  videos('Видео', 'videos', Icons.videocam);

  final String label;
  final String slug;
  final IconData icon;

  const BlockType(this.label, this.slug, this.icon);

  Map<String, dynamic> toMap() {
    return {
      'blockType': slug,
    };
  }

  static BlockType fromMap(Map<String, dynamic> map) {
    final mapSlug = map['blockType'] as String?;
    return BlockType.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => BlockType.text,
    );
  }
}

enum TextType {
  title(
    label: 'Заголовок',
    slug: 'title',
    size: 22,
    weight: FontWeight.w700,
    icon: Icons.format_size, // Или Icons.title
  ),
  subtitle(
    label: 'Подзаголовок',
    slug: 'subtitle',
    size: 20,
    weight: FontWeight.w600,
    icon: Icons.format_align_left,
  ),
  text(
    label: 'Текст',
    slug: 'text',
    size: 18,
    weight: FontWeight.w500,
    icon: Icons.notes,
  );

  final String label;
  final String slug;
  final double size;
  final FontWeight weight;
  final IconData icon; // Новое поле

  const TextType({
    required this.label,
    required this.slug,
    required this.size,
    required this.weight,
    required this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'textType': slug,
    };
  }

  static TextType fromMap(Map<String, dynamic> map) {
    final mapSlug = map['textType'] as String?;
    return TextType.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => TextType.text,
    );
  }
}

enum MethodView {
  tiles('Плитки', 'tiles', Icons.grid_view_rounded),
  slider('Слайдер', 'slider', Icons.view_carousel_rounded);

  final String label;
  final String slug;
  final IconData icon;

  const MethodView(this.label, this.slug, this.icon);

  Map<String, dynamic> toMap() {
    return {
      'methodView': slug,
    };
  }

  // Получаем из Map от сервера
  static MethodView fromMap(Map<String, dynamic> map) {
    final mapSlug = map['methodView'] as String?;
    return MethodView.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => MethodView.tiles,
    );
  }
}