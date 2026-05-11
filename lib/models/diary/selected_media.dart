import 'dart:io';

import 'package:dia_room/models/enums/diary/attachment_type.dart';

class SelectedMedia {
  final File file;
  final String? thumbnail;
  final AttachmentType type;

  SelectedMedia({required this.file, this.thumbnail, required this.type});
}