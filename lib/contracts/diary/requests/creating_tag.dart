import 'dart:ui';

class CreatingTag {
  final String name;
  final int color;

  CreatingTag({required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "color": color
    };
  }
}