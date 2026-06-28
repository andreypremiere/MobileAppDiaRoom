import 'dart:io';

import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../configuration/constants.dart';
import '../../models/post_creator/block_video.dart';

class VideoBlockWidget extends StatefulWidget {
  final BlockVideoCreating block;
  final VoidCallback onChanged;

  const VideoBlockWidget({super.key, required this.block, required this.onChanged});

  @override
  State<VideoBlockWidget> createState() => _VideoBlockWidgetState();
}

class _VideoBlockWidgetState extends State<VideoBlockWidget> {
  bool _isProcessing = false;

  Future<void> _pickVideo(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      if (mounted) {
        setState(() => _isProcessing = true);
      }
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);

      if (video == null) {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      final file = File(video.path);
      final bytes = await file.length();

      if (bytes > limitSizeVideoInPost) {
        await widget.block.clearBlock();
        if (context.mounted) {
          AppInfoDialog.show(context, "Максимальный размер видео ${limitSizeVideoInPost / (1024 * 1024)} мб.");
        }
        if (mounted) {
          setState(() => _isProcessing = false);
        }
        return;
      }

      final resultLoad = await widget.block.loadMetadata(video.path, bytes);
      final resultPreview = await widget.block.generatePreview();

      if (!resultPreview || !resultLoad) {
        if (context.mounted) {
          await AppInfoDialog.show(context, "Не удалось получить метаданные файла. Пожалуйста, сообщите в поддержку.");
        }
        await widget.block.clearBlock();
      }
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      widget.onChanged();
    } catch (e) {
      if (context.mounted) {
        AppInfoDialog.show(context, "Возникла непредвиденная ошибка при добавлении видеоролика. Пожалуйста, сообщите в поддержку.");
      }
      await widget.block.clearBlock();
    }

  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.localPath.isEmpty && !_isProcessing) {
      return _buildAddButton();
    }

    if (_isProcessing) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildSquarePreview(),
          const SizedBox(width: 12),

          Expanded(
            child: _buildVideoInfo(),
          ),
          const SizedBox(width: 8),

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
            onTap: () => {_pickVideo(context)},
            child: Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                color: context.ui.containerColor,
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
          File(widget.block.previewLocalPath),
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
        Text(
          widget.block.fileName,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),

        Row(
          children: [
            const Icon(Icons.access_time_filled, size: 16, color: Color(0xFF797979)),
            const SizedBox(width: 4),
            Text(
              widget.block.getFormattedDuration(),
              style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.storage_rounded, size: 16, color: Color(0xFF797979)),
            const SizedBox(width: 4),
            Text(
              widget.block.getStringFileSize(),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: IconButton(
        constraints: const BoxConstraints(),
        visualDensity: VisualDensity.compact,        padding: const EdgeInsets.all(8),
        onPressed: () async {
          await widget.block.clearBlock();
          widget.onChanged();
        },
        icon: const Icon(
          Icons.delete_outline,
          color: Color(0xFF696969),
          size: 22,
        ),
      ),
    );
  }
}