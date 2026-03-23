import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:uuid/uuid.dart';

class UploadFileInfo {
  final String uploadId;
  final String localPath;
  final String filename;
  final String contentType;
  final BlockPost parentBlock;
  final int? indexInBlock;         // для массивов (например, 3-й элемент в photos)
  final bool isVideoPreview;       // true = это thumbnail видео

  UploadFileInfo({
    required this.localPath,
    required this.filename,
    required this.contentType,
    required this.parentBlock,
    this.indexInBlock,
    this.isVideoPreview = false,
  }) : uploadId = const Uuid().v4();

  @override
  String toString() {
    // Короткий ID для читаемости (первые 8 символов)
    final shortId = uploadId.split('-').first;

    // Формируем строку с указанием индекса, если он есть
    final indexSuffix = indexInBlock != null ? '[$indexInBlock]' : '';

    return '''
UploadFileInfo {
  id: $shortId,
  file: $filename (${contentType.split('/').last}),
  type: ${isVideoPreview ? 'VIDEO_THUMBNAIL' : 'ORIGINAL'},
  parent: ${parentBlock.type.name}$indexSuffix,
  path: $localPath
}''';
  }
}