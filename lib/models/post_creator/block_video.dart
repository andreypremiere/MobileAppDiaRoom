import 'dart:io';

import 'package:dia_room/models/enums/post_types.dart';
import 'package:dia_room/models/post_creator/block_post.dart';
import 'package:get_thumbnail_video/index.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';


class BlockVideo extends BlockPost {
  String? path;
  String? fileName;
  String? previewPath;
  String? fileSize;
  Duration? duration;

  BlockVideo() : super(type: BlockPostType.videos);

  // Метод для загрузки метаданных и вывода в консоль
  Future<void> loadMetadata(String videoPath) async {
    path = videoPath;
    final file = File(videoPath);
    final bytes = await file.length();

    // Переводим в МБ
    double sizeInMb = bytes / (1024 * 1024);
    fileSize = "${sizeInMb.toStringAsFixed(2)} MB";
    fileName = videoPath.split('/').last;

    // Получаем длительность через временный контроллер
    final controller = VideoPlayerController.file(file);
    await controller.initialize();
    duration = controller.value.duration;

    print("--- Video Metadata ---");
    print("File: $fileName");
    print("Size: $fileSize");
    print("Duration: ${duration?.inSeconds} sec");
    print("----------------------");

    await controller.dispose();
  }

  Future<void> generatePreview() async {
    if (path == null) return;

    // Генерируем превью во временную папку телефона
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: path!,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxHeight: 300, // Ограничиваем размер для экономии памяти
      quality: 75,    // Баланс между качеством и весом файла
    );

    previewPath = uint8list.path;
    print("Превью создано: $previewPath");
  }

  String getformattedDuration(Duration? duration) {
    if (duration == null) return "0:00";
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void clearBlock() {
    path = null;
    fileName = null;
    previewPath = null;
    fileSize = null;
    duration = null;
  }
}