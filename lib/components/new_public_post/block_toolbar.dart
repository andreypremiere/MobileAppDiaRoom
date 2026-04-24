import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../../models/enums/post_types.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_post.dart';
import '../../models/post_creator/block_text.dart';

/// Виджет панели инструментов для редактирования конкретного блока контента.
/// Позволяет изменять тип текста или способ отображения фотографий.
class PostToolbar extends StatelessWidget {
  final BlockPost block;
  final VoidCallback onChanged;

  const PostToolbar({
    super.key,
    required this.block,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: _buildContent(context),
      ),
    );
  }

  /// Определяет, какой набор инструментов показать в зависимости от типа [block]
  Widget _buildContent(BuildContext context) {
    if (block is BlockTextCreating) {
      return _buildTextToolbar(context, block as BlockTextCreating);
    }
    if (block is BlockPhotosCreating) {
      return _buildPhotoToolbar(context, block as BlockPhotosCreating);
    }
    return const SizedBox();
  }

  /// Собирает инструменты для работы с текстовым блоком (заголовки, подзаголовки)
  Widget _buildTextToolbar(BuildContext context, BlockTextCreating textBlock) {
    return Row(
      children: [
        _buildPopupSelector<TextType>(
          context: context,
          currentLabel: textBlock.textType.label,
          items: TextType.values,
          onSelected: (value) {
            textBlock.textType = value;
            onChanged();
          },
          itemLabel: (type) => type.label,
          iconBuilder: (type) => type.icon,
          isSelected: (type) => textBlock.textType == type,
        ),
      ],
    );
  }

  /// Собирает инструменты для работы с блоком фотографий (сетка или карусель)
  Widget _buildPhotoToolbar(BuildContext context, BlockPhotosCreating photoBlock) {
    return Row(
      children: [
        _buildPopupSelector<MethodViewPhoto>(
          context: context,
          currentLabel: photoBlock.methodView.label,
          items: MethodViewPhoto.values,
          onSelected: (value) {
            photoBlock.methodView = value;
            onChanged();
          },
          itemLabel: (type) => type.label,
          iconBuilder: (type) => type == MethodViewPhoto.tiles ? Icons.grid_view : Icons.view_carousel,
          isSelected: (type) => photoBlock.methodView == type,
        ),
      ],
    );
  }

  /// Универсальный компонент для выбора параметров через выпадающее меню
  Widget _buildPopupSelector<T>({
    required BuildContext context,
    required String currentLabel,
    required List<T> items,
    required Function(T) onSelected,
    required String Function(T) itemLabel,
    required IconData Function(T) iconBuilder,
    required bool Function(T) isSelected,
  }) {
    return PopupMenuButton<T>(
      onOpened: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.ui.containerColor,
      elevation: 5,
      offset: const Offset(0, 45),
      onSelected: onSelected,
      child: Container(
        // width: 120,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: context.ui.toolbarItemColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(
            currentLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, color: context.ui.fontColorPrimary),
          ),
        ),
      ),
      itemBuilder: (context) => items.map((type) {
        return PopupMenuItem<T>(
          height: 40,
          value: type,
          child: Row(
            children: [
              Icon(iconBuilder(type), color: context.ui.fontColorPrimary, size: 18),
              const SizedBox(width: 8),
              Text(
                itemLabel(type),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected(type) ? FontWeight.w600 : FontWeight.w500,
                  color: context.ui.fontColorPrimary,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}