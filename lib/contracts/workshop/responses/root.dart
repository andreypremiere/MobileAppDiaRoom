import '../../../models/workshop/Folder.dart';

class Root {
  List<Folder> folders;

  Root({required this.folders});

  factory Root.fromMap(Map<String, dynamic> map) {
    return Root(
      folders: (map['folders'] as List<dynamic>?)
          ?.map((item) => Folder.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}