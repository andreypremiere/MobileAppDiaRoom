import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../models/diary/tag.dart';

class TagChip extends StatelessWidget {
  final MessageTag tag;
  final bool isSelected;
  final Function(bool)? onSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String id)? onClose;

  const TagChip({
    super.key,
    required this.tag,
    this.isSelected = false,
    this.onSelected,
    this.onTap,
    this.onLongPress,
    this.onClose
  });

  @override
  Widget build(BuildContext context) {
    final Color tagColor = tag.color;
    final bool active = isSelected || onSelected == null;

    return GestureDetector(
      onLongPress: onLongPress,
      onTap: onTap,
      child:
      FilterChip(
        backgroundColor: context.ui.containerColor,
        visualDensity: VisualDensity.compact,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label_outline,
              size: 14,
              color: active ? tagColor : context.ui.fontColorPrimary.withOpacity(0.5),
            ),
            const SizedBox(width: 4),
            Text(
              tag.name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: active ? tagColor : context.ui.fontColorPrimary,
              ),
            ),
          ],
        ),
        onDeleted: onClose != null ? () => onClose!(tag.id) : null,
        deleteIcon: const Icon(Icons.close, size: 14),
        deleteIconColor: active ? tagColor : context.ui.fontColorPrimary.withOpacity(0.5),

        selected: isSelected,
        onSelected: onSelected ?? (onClose != null ? (bool value) {} : null),
        selectedColor: tagColor.withOpacity(0.12),
        side: BorderSide(
          color: active
              ? tagColor.withOpacity(0.4)
              : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
        showCheckmark: false,
      ),
    );
  }
}