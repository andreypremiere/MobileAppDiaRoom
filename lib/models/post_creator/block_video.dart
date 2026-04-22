import 'dart:io';

import 'package:dia_room/models/internal_error.dart';
import 'package:dia_room/models/payload/base_block.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

import '../payload/post_creating_interface.dart';


class BlockVideoCreating extends VideoBlockPost implements Validatable {
  BlockVideoCreating()
      : super(
    localPath: '',
    publicUrl: '',
    presignedUrl: '',
    previewLocalPath: '',
    previewPublicUrl: '',
    previewPresignedUrl: '',
    fileSize: 0,
    duration: Duration.zero,
  );

  String getStringFileSize() {
    if (fileSize != 0) {
      return "${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB";
    }
    else {
      return "size is not defined";
    }
  }

  Future<Result> loadMetadata(String videoPath, int length) async {
    try {
      localPath = videoPath;
      final file = File(videoPath);
      fileSize = length;

      // Получаем длительность через временный контроллер
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      duration = controller.value.duration;
      await controller.dispose();
    } catch (e) {
      return Result(result: false, message: 'Ошибка при загрузке метаданных');
    }
    return Result(result: true, message: '');
  }

  Future<Result> generatePreview() async {
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: localPath,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 600,
      quality: 90,
    );

    previewLocalPath = uint8list.path;
    // print("Превью создано: $previewPath");
    return Result(result: true, message: '');
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
    if (await File(localPath).exists()) await File(localPath).delete();

    if (await File(previewLocalPath).exists()) await File(previewLocalPath).delete();


    localPath = '';
    publicUrl = '';
    presignedUrl = '';
    previewLocalPath = '';
    previewPublicUrl = '';
    previewPresignedUrl = '';
    fileSize = 0;
    duration: Duration.zero;
  }

  bool isEmpty() {
    return localPath.isEmpty;
  }
}

