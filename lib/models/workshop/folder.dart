class Folder {
  final String id;
  final String roomId;
  final String? parentId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder({
    required this.id,
    required this.roomId,
    this.parentId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Folder.fromMap(Map<String, dynamic> map) {
    return Folder(
      id: map['id'] ?? '',
      roomId: map['roomId'] ?? '',
      parentId: map['parentId'] as String?,
      name: map['name'] ?? 'Без названия',

      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),

      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'roomId': roomId,
      'parentId': parentId,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Folder(id: $id, name: $name, parentId: $parentId)';
  }
}