import 'package:flutter/material.dart';

enum PostStatus {
  draft('Черновик', Colors.grey),
  pending('Ожидает публикации', Colors.orange),
  processing('Обработка файлов...', Colors.blue),
  published('Опубликовано', Colors.green),
  hidden('Скрыто', Colors.blueGrey),
  rejected('Отклонено', Colors.red),
  deleted('Удалено', Colors.black54);

  final String label;
  final Color color;

  const PostStatus(this.label, this.color);

  // Метод для безопасного парсинга из строки бэкенда
  static PostStatus fromString(String value) {
    return PostStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => PostStatus.draft,
    );
  }
}