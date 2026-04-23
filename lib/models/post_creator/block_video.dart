import 'dart:io';

import 'package:dia_room/models/enums/post_types.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

// Переделать это

class BlockVideoCreating extends BlockPost {
  String? path;
  String? fileName;
  String? previewPath;
  int? fileSize;
  Duration? duration;

  BlockVideoCreating() : super(type: BlockType.videos);

  String getStringFileSize() {
    if (fileSize != null) {
      return "${(fileSize! / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    else {
      return "";
    }
  }

  /// Подгружает имя файла, размер файла, длительность файла
  Future<bool> loadMetadata(String videoPath, int length) async {
    try {
      path = videoPath;
      final file = File(videoPath);
      // final bytes = await file.length();

      fileSize = length;
      fileName = videoPath
          .split('/')
          .last;

      // Получаем длительность через временный контроллер
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      duration = controller.value.duration;
      await controller.dispose();
    } catch (e) {
      return false;
    }
    return true;
  }

  Future<bool> generatePreview() async {
    if (path == null) return false;

    final uint8list = await VideoThumbnail.thumbnailFile(
      video: path!,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 600,
      quality: 90,
    );

    previewPath = uint8list.path;
    // print("Превью создано: $previewPath");
    return true;
  }

  String getformattedDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Future<void> clearBlock() async {
    if (path != null) {
      if (await File(path!).exists()) await File(path!).delete();
    }

    if (previewPath != null) {
      if (await File(previewPath!).exists()) await File(previewPath!).delete();
    }

    path = null;
    fileName = null;
    previewPath = null;
    fileSize = null;
    duration = null;
  }

  @override
  bool isEmpty() {
    return path?.isEmpty ?? true;
  }
}

class BlockVideoUpload extends BlockUpload {
  String filePath;
  String previewPath;
  int fileSize;
  Duration duration;

  String uploadIdVideo;
  String uploadIdPreview;

  String? publicUrlVideo;
  String? publicUrlPreview;

  String? presignedUrlVideo;
  String? presignedUrlPreview;

  BlockVideoUpload({
    required this.filePath,
    required this.previewPath,
    required this.fileSize,
    required this.duration,
    required this.uploadIdVideo,
    required this.uploadIdPreview
}) : super(type: BlockType.videos);

  @override
  Map<String, dynamic> toJson() {
    return {
      'blockType': type.slug, // videos
      'fileSize': fileSize,
      'durationMs': duration.inMilliseconds, // Длительность лучше хранить в мс
      'uploadIdVideo': uploadIdVideo,
      'uploadIdPreview': uploadIdPreview,
      'publicUrlVideo': publicUrlVideo,
      'publicUrlPreview': publicUrlPreview,
    };
  }


}