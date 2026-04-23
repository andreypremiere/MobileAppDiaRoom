import 'dart:io';

import 'package:dia_room/models/enums/post_types.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class BlockVideo extends BlockPost {
  String localPath;
  String publicUrl;

  String fileName;

  String previewLocalPath;
  String previewPublicUrl;

  int fileSize;
  Duration duration;

  BlockVideo({
    required this.localPath,
    required this.publicUrl,
    required this.previewLocalPath,
    required this.fileName,
    required this.previewPublicUrl,
    required this.fileSize,
    required this.duration,
  }) : super(type: BlockType.videos);

}

class BlockVideoCreating extends BlockVideo implements Validatable {
  String presignedUrl;
  String previewPresignedUrl;

  BlockVideoCreating({
    required this.presignedUrl,
    required this.previewPresignedUrl,
    required super.localPath,
    required super.publicUrl,
    required super.previewLocalPath,
    required super.fileName,
    required super.previewPublicUrl,
    required super.fileSize,
    super.duration = Duration.zero,
  });

  String getStringFileSize() {
    if (fileSize != 0) {
      return "${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    else {
      return "";
    }
  }

  /// Подгружает имя файла, размер файла, длительность файла
  Future<bool> loadMetadata(String videoPath, int length) async {
    try {
      localPath = videoPath;
      final file = File(videoPath);

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
    if (localPath.isEmpty) return false;

    final uint8list = await VideoThumbnail.thumbnailFile(
      video: localPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 600,
      quality: 90,
    );

    previewLocalPath = uint8list.path;
    return true;
  }

  String getFormattedDuration() {
    if (duration == Duration.zero) return "-:--";

    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      // Формат H:MM:SS
      return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
    } else {
      // Формат M:SS
      return "${duration.inMinutes}:${twoDigits(seconds)}";
    }
  }

  Future<void> clearBlock() async {
    if (localPath.isNotEmpty) {
      if (await File(localPath).exists()) await File(localPath).delete();
    }

    if (previewLocalPath.isNotEmpty) {
      if (await File(previewLocalPath).exists()) await File(previewLocalPath).delete();
    }

    localPath = '';
    publicUrl = '';
    presignedUrl = '';
    previewLocalPath = '';
    previewPublicUrl = '';
    previewPresignedUrl = '';
    fileSize = 0;
    duration = Duration.zero;
  }

  @override
  bool isEmpty() {
    return localPath.isEmpty;
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
      // 'uploadIdVideo': uploadIdVideo,
      // 'uploadIdPreview': uploadIdPreview,
      'publicUrlVideo': publicUrlVideo,
      'publicUrlPreview': publicUrlPreview,
    };
  }


}