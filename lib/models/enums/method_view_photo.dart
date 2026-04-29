import 'package:flutter/material.dart';

enum MethodViewPhoto {
  tiles('Плитки', 'tiles', Icons.grid_view_rounded),
  slider('Слайдер', 'slider', Icons.view_carousel_rounded);

  final String label;
  final String slug;
  final IconData icon;

  const MethodViewPhoto(this.label, this.slug, this.icon);

  Map<String, dynamic> toMap() {
    return {
      'methodViewPhoto': slug,
    };
  }

  // Получаем из Map от сервера
  static MethodViewPhoto fromMap(Map<String, dynamic> map) {
    final mapSlug = map['methodViewPhoto'] as String?;
    return MethodViewPhoto.values.firstWhere(
          (e) => e.slug == mapSlug,
      orElse: () => MethodViewPhoto.tiles,
    );
  }
}