import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/models/enums/workshop/item_status.dart';
import 'package:dia_room/models/enums/workshop/item_type.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/material.dart';
import '../../models/enums/workshop/item_actions.dart'; // Создай этот Enum по аналогии с папками
import '../../models/workshop/item.dart';

class FileItem extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;
  final Function(ItemAction) onActionSelected;
  final bool canEdit;

  const FileItem({
    super.key,
    required this.item,
    required this.onTap,
    required this.onActionSelected,
    this.canEdit = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Сначала рисуем контент (картинку/статус)
          _buildMainContent(context),

          // 2. Иконка типа
          Positioned(top: 8, left: 8, child: _buildTypeBadge(context)),

          // 3. Статус
          if (item.status == ItemStatus.uploading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),

          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onLongPressStart: canEdit
                    ? (details) {
                  _showContextMenu(context, details);
                      }
                    : null,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    if (item.status != ItemStatus.ready) {
      return Container(
        color: context.ui.containerColor.withOpacity(0.5),
        child: Icon(
          item.status == ItemStatus.failed
              ? Icons.error_outline_rounded
              : Icons.cloud_upload_outlined,
          color: item.status == ItemStatus.failed
              ? Colors.redAccent
              : Colors.grey,
          size: 32,
        ),
      );
    }

    // Твой готовый метод для кэшированных изображений
    return buildRectangleImage(
      item.previewUrl != null ? getFullUrl(item.previewUrl!) : "",
    );
  }

  Widget _buildTypeBadge(BuildContext context) {
    final bool isVideo = item.itemType == ItemType.video;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isVideo ? Icons.play_arrow_rounded : Icons.photo_rounded,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  // Метод для отрисовки ошибки загрузки изображения
  Widget _buildErrorWidget(BuildContext context) {
    return Container(
      color: context.ui.containerColor.withOpacity(0.3),
      child: Icon(
        Icons.broken_image_rounded,
        color: context.ui.fontColorPrimary.withOpacity(0.5),
        size: 32,
      ),
    );
  }

  // Заглушка для твоего метода
  Widget buildRectangleImage(String imageUrl, {double borderRadius = 0}) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      // ВАЖНО: оборачиваем в IgnorePointer, чтобы картинка не перехватывала жесты
      imageBuilder: (context, imageProvider) => IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
      ),
      placeholder: (context, url) => IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            color: context.ui.containerColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        decoration: BoxDecoration(
          color: context.ui.containerColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: _buildErrorWidget(context),
      ),
    );
  }

  void _showContextMenu(
      BuildContext context,
      LongPressStartDetails details,
      ) async {
    // 1. Получаем RenderBox оверлея
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    // 2. Преобразуем глобальную позицию в локальную для оверлея
    final Offset localPosition = overlay.globalToLocal(details.globalPosition);

    // 3. Используем полученную точку для создания Rect
    final result = await showMenu<ItemAction>(
      context: context,
      position: RelativeRect.fromRect(
        localPosition & const Size(40, 40), // Размер блока для меню
        Offset.zero & overlay.size,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.ui.containerColor,
      items: [
        _buildPopupItem(
          context,
          value: ItemAction.move,
          icon: Icons.drive_file_move_outline,
          label: 'Переместить',
        ),
        _buildPopupItem(
          context,
          value: ItemAction.delete,
          icon: Icons.delete_outline_rounded,
          label: 'Удалить',
          isDanger: true,
        ),
      ],
    );

    if (result != null) onActionSelected(result);
  }

  PopupMenuItem<ItemAction> _buildPopupItem(
    BuildContext context, {
    required ItemAction value,
    required IconData icon,
    required String label,
    bool isDanger = false,
  }) {
    final color = isDanger ? Colors.redAccent : context.ui.fontColorPrimary;
    return PopupMenuItem<ItemAction>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
