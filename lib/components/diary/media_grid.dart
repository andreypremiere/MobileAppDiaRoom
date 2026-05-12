import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../models/diary/attachment.dart';
import '../../models/enums/diary/attachment_type.dart';

class MediaGrid extends StatelessWidget {
  final List<Attachment> attachments;
  const MediaGrid({super.key, required this.attachments});

  @override
  Widget build(BuildContext context) {
    int count = attachments.length;
    if (count == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _buildLayout(count),
      ),
    );
  }

  Widget _buildLayout(int count) {
    switch (count) {
      case 1:
        return _item(attachments[0], height: 250);
      case 2:
        return Row(
          children: [
            Expanded(child: _item(attachments[0], height: 200)),
            const SizedBox(width: 2),
            Expanded(child: _item(attachments[1], height: 200)),
          ],
        );
      case 3:
        return Column(
          children: [
            _item(attachments[0], height: 180),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(child: _item(attachments[1], height: 120)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[2], height: 120)),
              ],
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            // Верхний ряд: 2 больших фото
            Row(
              children: [
                Expanded(child: _item(attachments[0], height: 180)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[1], height: 180)),
              ],
            ),
            const SizedBox(height: 2),
            // Нижний ряд: 3 маленьких фото
            Row(
              children: [
                Expanded(child: _item(attachments[2], height: 110)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[3], height: 110)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[4], height: 110)),
              ],
            ),
          ],
        );
      case 7:
        return Column(
          children: [
            // Верхний ряд: 3 маленьких фото
            Row(
              children: [
                Expanded(child: _item(attachments[0], height: 100)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[1], height: 100)),
                const SizedBox(width: 2),
                Expanded(child: _item(attachments[2], height: 100)),
              ],
            ),
            const SizedBox(height: 2),
            // Сетка снизу: 4 фото (2x2)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 1.5,
              children: [
                _item(attachments[3]),
                _item(attachments[4]),
                _item(attachments[5]),
                _item(attachments[6]),
              ],
            ),
          ],
        );
      default:
      // Для 4, 6 и более 7 вложений (стандартная сетка)
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: count,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 2,
            mainAxisSpacing: 2,
            childAspectRatio: 1.5,
          ),
          itemBuilder: (context, index) => _item(attachments[index]),
        );
    }
  }

  Widget _item(Attachment att, {double? height}) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CachedNetworkImage(
          imageUrl: att.previewS3Key ?? "",
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
          // Отображается во время загрузки
          placeholder: (context, url) => Container(
            color: context.ui.fontColorHint.withAlpha(50),
            child: const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          // Отображается при ошибке (например, 404 или нет сети)
          errorWidget: (context, url, error) => Container(
            color: context.ui.fontColorHint.withAlpha(30),
            child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
          ),
        ),

        // Если это видео — накладываем иконку поверх закешированного превью
        if (att.attType == AttachmentType.video || att.attType == AttachmentType.videoNote)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.black26,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
      ],
    );
  }
}