import 'package:flutter/material.dart';
import '../../models/enums/post_types.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_post.dart';
import '../../models/post_creator/block_text.dart';
import '../../models/canvas.dart'; // Предполагаю, тут базовый класс BlockPost

class PostToolbar extends StatelessWidget {
  final BlockPost block;
  final VoidCallback onChanged; // Этот колбэк заменит setState

  const PostToolbar({
    super.key,
    required this.block,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Обертка со скроллом теперь внутри самого виджета
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (block is BlockText) {
      return _buildTextToolbar(block as BlockText);
    }
    if (block is BlockPhotos) {
      return _buildPhotoToolbar(block as BlockPhotos);
    }
    return const SizedBox();
  }

  // --- ТУЛБАР ДЛЯ ТЕКСТА ---
  Widget _buildTextToolbar(BlockText textBlock) {
    return Row(
      children: [
        _buildPopupSelector<TextType>(
          currentLabel: textBlock.textType.label,
          items: TextType.values,
          onSelected: (value) {
            textBlock.textType = value;
            // Логика стилей
            if (value == TextType.header) {
              textBlock.metadata['size'] = 22;
              textBlock.metadata['weight'] = 800;
            } else if (value == TextType.subtitle) {
              textBlock.metadata['size'] = 18;
              textBlock.metadata['weight'] = 600;
            } else {
              textBlock.metadata['size'] = 16;
              textBlock.metadata['weight'] = 400;
            }
            onChanged(); // Уведомляем главный экран
          },
          itemLabel: (type) => type.label,
          // Проверка на заголовок для иконки
          iconBuilder: (type) => type == TextType.header ? Icons.title : Icons.notes,
          isSelected: (type) => textBlock.textType == type,
        ),
      ],
    );
  }

  // --- ТУЛБАР ДЛЯ ФОТО ---
  Widget _buildPhotoToolbar(BlockPhotos photoBlock) {
    return Row(
      children: [
        _buildPopupSelector<MethodViewPhoto>(
          currentLabel: photoBlock.methodView.label,
          items: MethodViewPhoto.values,
          onSelected: (value) {
            photoBlock.methodView = value;
            onChanged(); // Уведомляем главный экран
          },
          itemLabel: (type) => type.label,
          iconBuilder: (type) => type == MethodViewPhoto.tiles ? Icons.grid_view : Icons.view_carousel,
          isSelected: (type) => photoBlock.methodView == type,
        ),
      ],
    );
  }

  // --- УНИВЕРСАЛЬНЫЙ ШАБЛОН КНОПКИ (чтобы не дублировать дизайн) ---
  Widget _buildPopupSelector<T>({
    required String currentLabel,
    required List<T> items,
    required Function(T) onSelected,
    required String Function(T) itemLabel,
    required IconData Function(T) iconBuilder,
    required bool Function(T) isSelected,
  }) {
    return PopupMenuButton<T>(
      onOpened: () {
        // Жестко снимаем фокус до открытия меню
        FocusManager.instance.primaryFocus?.unfocus();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 5,
      offset: const Offset(0, 45),
      onSelected: onSelected,
      child: Container(
        width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF525252),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            currentLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 14, color: Colors.white),
          ),
        ),
      ),
      itemBuilder: (context) => items.map((type) {
        return PopupMenuItem<T>(
          height: 40,
          value: type,
          child: Row(
            children: [
              Icon(iconBuilder(type), color: const Color(0xFF797979), size: 18),
              const SizedBox(width: 8),
              Text(
                itemLabel(type),
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'SNPro',
                  fontWeight: isSelected(type) ? FontWeight.w600 : FontWeight.w500,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}