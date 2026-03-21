import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_creator/block_video.dart';

class VideoBlockWidget extends StatefulWidget {
  final BlockVideo block;
  final VoidCallback onChanged;

  const VideoBlockWidget({super.key, required this.block, required this.onChanged});

  @override
  State<VideoBlockWidget> createState() => _VideoBlockWidgetState();
}

class _VideoBlockWidgetState extends State<VideoBlockWidget> {
  // VideoPlayerController? _controller;
  bool _isProcessing = false;

  // @override
  // void initState() {
  //   super.initState();
  //   if (widget.block.path != null) {
  //     _initController();
  //   }
  // }

  // void _initController() {
  //   _controller = VideoPlayerController.file(File(widget.block.path!))
  //     ..initialize().then((_) => setState(() {}));
  // }

  Future<void> _pickVideo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      final file = File(video.path);
      final bytes = await file.length();

      // Проверка на 200 МБ
      if (bytes > 200 * 1024 * 1024) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Файл слишком большой (макс. 200 МБ)")),
        );
        return;
      }
      setState(() => _isProcessing = true);

      await widget.block.loadMetadata(video.path);
      await widget.block.generatePreview();
      // _initController();
      setState(() => _isProcessing = false);

      widget.onChanged();
    }
  }

  // @override
  // void dispose() {
  //   _controller?.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    // Если видео нет и оно не обрабатывается, показываем кнопку добавления
    if (widget.block.path == null && !_isProcessing) {
      return _buildAddButton();
    }

    // Если видео обрабатывается, показываем индикатор загрузки
    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    // Дизайн в виде СТРОКИ (Row)
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Квадратное превью (100x100)
          _buildSquarePreview(),
          const SizedBox(width: 12), // Отступ между превью и текстом

          // 2. Блок с текстом (Имя, Время, Размер)
          // Используем Expanded, чтобы текст занимал всё оставшееся место,
          // но не выдавливал иконку удаления.
          Expanded(
            child: _buildVideoInfo(),
          ),
          const SizedBox(width: 8),

          // 3. Кнопка удаления в самом конце (Справа)
          _buildDeleteIcon(),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: _pickVideo,
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFC9C9C9)),
              ),
              child: const Icon(Icons.video_call_outlined, color: Color(0xFF797979), size: 36),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquarePreview() {
    return Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFC9C9C9)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Image.file(
          File(widget.block.previewPath!),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Имя файла (жирное, с обрезкой)
        Text(
          widget.block.fileName ?? 'Без названия',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1, // Чтобы имя не ломалось на две строки
          overflow: TextOverflow.ellipsis, // Три точки, если имя очень длинное
        ),
        const SizedBox(height: 6),

        // Вторая строка (Длительность | Размер)
        Row(
          children: [
            const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF797979)),
            const SizedBox(width: 4),
            Text(
              widget.block.getformattedDuration(widget.block.duration),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            const SizedBox(width: 12), // Отступ между временем и размером
            const Icon(Icons.storage_rounded, size: 16, color: Color(0xFF797979)),
            const SizedBox(width: 4),
            Text(
              widget.block.fileSize ?? '0 MB',
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeleteIcon() {
    return Container(
      padding: EdgeInsets.all(2),
      // margin: const EdgeInsets.only(left: 8), // Небольшой отступ от текста
      decoration: BoxDecoration(
        color: Colors.white, // Белый фон круга
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10), // Легкая тень, чтобы круг не сливался с фоном
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        // 2. Схлопываем лишние внутренние отступы темы
        visualDensity: VisualDensity.compact,        padding: const EdgeInsets.all(8),    // Настраиваем внутренний отступ
        onPressed: () {
          widget.block.clearBlock(); // Убедись, что имя поля совпадает (thumbnailPath)
          widget.onChanged();
        },
        icon: const Icon(
          Icons.delete_outline,
          color: Color(0xFF696969),
          size: 22, // Чуть уменьшил размер для баланса внутри круга
        ),
      ),
    );
  }
}