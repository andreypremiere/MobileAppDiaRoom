import 'package:flutter/material.dart';
import '../../models/diary/tag.dart';
import 'tag_chip.dart';

class TagsWidget extends StatelessWidget {
  final List<MessageTag> tags;
  final Function(MessageTag tag)? onTagTap;
  final Function(MessageTag tag)? onTagLongPress;
  final Function(MessageTag tag)? onTagClose;
  final List<MessageTag>? selectedTags;
  final Function(MessageTag tag, bool isSelected)? onTagSelected;
  final double spacing; // Горизонтальное расстояние между тегами
  final double runSpacing; // Вертикальное расстояние между строками
  final EdgeInsets padding; // Внутренние отступы

  const TagsWidget({
    super.key,
    required this.tags,
    this.onTagTap,
    this.onTagLongPress,
    this.onTagClose,
    this.selectedTags,
    this.onTagSelected,
    this.spacing = 8,
    this.runSpacing = 4,
    this.padding = const EdgeInsets.symmetric(horizontal: 6),
  });

  @override
  Widget build(BuildContext context) {
    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: tags.map((tag) {
          return TagChip(
            tag: tag,
            isSelected: true,
            onTap: () => onTagTap?.call(tag),
            onLongPress: () => onTagLongPress?.call(tag),
            onSelected: onTagSelected != null
                ? (selected) => onTagSelected!(tag, selected)
                : null,
            onClose: onTagClose != null
                ? (id) => onTagClose!(tag)
                : null,
          );
        }).toList(),
      ),
    );
  }
}