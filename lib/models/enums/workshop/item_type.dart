import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ItemType {
  photo(Icons.photo, 'photo'),
  video(Icons.play_arrow_rounded, 'video');

  final IconData icon;
  final String slug;

  const ItemType(this.icon, this.slug);

  static ItemType fromMap(Map<String, dynamic> map) {
    final mapSlug = map['itemType'] as String?;
    return ItemType.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => ItemType.photo,
    );
  }
}
