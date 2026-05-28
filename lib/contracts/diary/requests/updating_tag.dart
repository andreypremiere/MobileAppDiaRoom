class UpdatingTag {
  final String name;
  final int color;

  UpdatingTag({required this.name, required this.color});

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "color": color
    };
  }
}