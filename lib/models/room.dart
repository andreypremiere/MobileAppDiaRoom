import 'package:flutter/foundation.dart';

// Category описывает тематическую категорию, к которой относится комната
class Category {
  final String slug; // Уникальный строковый идентификатор категории
  final String name; // Отображаемое название категории

  Category({required this.slug, required this.name});

  // factory конструктор для создания экземпляра категории из JSON данных
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(slug: json['slug'] as String, name: json['name'] as String);
  }
}

// Room представляет полную модель данных комнаты со всеми её характеристиками
class Room {
  final String id;
  final String userId;
  final String roomName;
  final String roomNameId;
  final List<Category> categories;
  final String? avatarUrl; // Опциональное поле: ссылка на аватар
  final String? bio; // Опциональное поле: описание комнаты
  final Map<String, dynamic> settings;
  final int followersCount;
  final int followingCount;

  Room({
    required this.id,
    required this.userId,
    required this.roomName,
    required this.roomNameId,
    required this.categories,
    this.avatarUrl,
    this.bio,
    required this.settings,
    this.followersCount = 0,
    this.followingCount = 0,
  });

  // static метод для безопасного парсинга комнаты из JSON с обработкой исключений
  static Room? fromJson(Map<String, dynamic> json) {
    Room room;
    try {
      room = Room(
        id: json['id'] as String,
        userId: json['userId'] as String,
        roomName: json['roomName'] as String,
        roomNameId: json['roomNameId'] as String,
        // Преобразование списка динамических объектов в типизированный список Category
        categories:
            (json['categories'] as List<dynamic>?)
                ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String?,
        // Инициализация пустой мапой, если настройки не пришли с сервера
        settings: json['settings'] as Map<String, dynamic>? ?? {},
        followersCount: json['followersCount'] as int? ?? 0,
        followingCount: json['followingCount'] as int? ?? 0,
      );
    } catch (e) {
      // Логирование ошибки в случае несоответствия типов в JSON
      print('Возникла ошибка во время создания Room: $e');
      return null;
    }
    return room;
  }
}
