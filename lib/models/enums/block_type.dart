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
