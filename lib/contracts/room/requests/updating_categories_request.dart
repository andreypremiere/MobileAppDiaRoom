import 'package:dia_room/models/enums/categories.dart';

class UpdatingCategoriesRequest {
  final List<Categories> categories;

  const UpdatingCategoriesRequest({required this.categories});

  Map<String, dynamic> toMap() {
    return {
      'categories': categories.map((el) => el.slug).toList(),
    };
  }
}
