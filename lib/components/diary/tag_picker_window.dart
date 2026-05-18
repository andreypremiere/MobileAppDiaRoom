import 'package:dia_room/components/diary/tag_chip.dart';
import 'package:dia_room/contracts/diary/requests/creating_tag.dart';
import 'package:dia_room/contracts/diary/requests/updating_tag.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../api/diary_api.dart';
import '../../models/diary/tag.dart';

class TagPickerSheet extends StatefulWidget {
  final List<MessageTag> selectedTags;
  final String roomId;

  const TagPickerSheet({super.key, required this.selectedTags, required this.roomId});

  @override
  State<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends State<TagPickerSheet> {
  late List<MessageTag> _tempSelected;
  final TextEditingController _newTagController = TextEditingController();

  // Здесь будет загрузка из твоего API
  List<MessageTag> _allUserTags = [];
  bool _isLoading = true;

  int _selectedColorValue = 0xFF2196F3;

  final List<int> _availableColors = [
    0xFF2196F3, // Синий
    0xFF9C27B0, // Фиолетовый
    0xFFF44336, // Красный
    0xFF4CAF50, // Зеленый
    0xFFFF9800, // Оранжевый
    0xFF00BCD4, // Бирюзовый
    0xFFE91E63, // Розовый
    0xFF795548, // Коричневый
  ];

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.selectedTags);
    _loadTags();
  }

  Future<void> _handleAddNewTag() async {
    if (_newTagController.text.trim().isNotEmpty) {

      final response = await createTag(tag: CreatingTag(name: _newTagController.text.trim(), color: _selectedColorValue));

      if (!response.success) {
        print("Не удалось создать тег");
        return;
      }

      final MessageTag tag = MessageTag.fromMap(response.data);

      setState(() {
        _allUserTags.insert(0, tag);
        _tempSelected.add(tag);
        _newTagController.clear();
      });
    }
  }

  Future<void> _handleDeleteTag(MessageTag tag) async {
    final response = await deleteTag(tagId: tag.id);

    if (!response.success) {
      print("Не удалось удалить тег");
      return;
    }

    setState(() {
      _allUserTags.removeWhere((t) => t.id == tag.id);
      _tempSelected.removeWhere((t) => t.id == tag.id);
    });
    Navigator.pop(context); // Закрыть подтверждение
    Navigator.pop(this.context); // Закрыть основное окно редактирования
  }

  void _showColorGridDialog({required int currentColor, required Function(int) onColorSelected}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Выберите цвет"),
        backgroundColor: context.ui.containerColor,
        content: SizedBox(
          width: 250,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _availableColors.length,
            itemBuilder: (context, index) {
              final colorVal = _availableColors[index];
              return GestureDetector(
                onTap: () {
                  onColorSelected(colorVal);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(colorVal),
                    shape: BoxShape.circle,
                    border: currentColor == colorVal
                        ? Border.all(color: context.ui.fontColorPrimary, width: 3)
                        : null,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- Диалог редактирования / удаления тега ---
  void _showEditDeleteDialog(MessageTag tag) {
    final editController = TextEditingController(text: tag.name);
    int editColorValue = tag.color.toARGB32();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: context.ui.containerColor,
          title: const Text("Управление тегом"),
          content: IntrinsicHeight(
            child: SizedBox(height: 46,child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Квадратик цвета (высота как у TextField)
                AspectRatio(
                  aspectRatio: 1,
                  child: GestureDetector(
                    onTap: () => _showColorGridDialog(
                      currentColor: editColorValue,
                      onColorSelected: (newColor) => setDialogState(() => editColorValue = newColor),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(editColorValue),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.palette_outlined, color: Colors.white, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // 2. Поле ввода с иконкой удаления
                Expanded(
                  child: TextField(
                    controller: editController,
                    decoration: InputDecoration(
                      hintText: "Название тега",
                      contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                    ),
                  ),
                ),
                const SizedBox(width: 8,),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _confirmDelete(tag),
                ),
              ],
            ),),
          ),
          // Разводим кнопки по сторонам
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Отмена", style: TextStyle(color: context.ui.fontColorPrimary.withOpacity(0.6))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: context.ui.primaryColor,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (editController.text.trim().isEmpty) return;
                await _handleUpdateTag(tag, editController.text.trim(), editColorValue);
                Navigator.pop(context);
              },
              child: const Text("Сохранить", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

// Вспомогательный метод для подтверждения удаления
  void _confirmDelete(MessageTag tag) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.ui.containerColor,
        title: const Text("Удалить тега"),
        content: const Text(
          "Вы точно хотите удалить этот тег? В сообщениях существующий тег удалится безвозвратно.",
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Отмена"),
          ),
          TextButton(
            onPressed: () async {
              await _handleDeleteTag(tag);
            },
            child: const Text("Удалить", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

// Логика обновления
  Future<void> _handleUpdateTag(MessageTag tag, String newName, int newColor) async {
    final response = await updateTag(tagId: tag.id, tag: UpdatingTag(name: newName, color: newColor));

    if (!response.success) {
      print("Не удалось обновить тег;");
    }

    final MessageTag newTag = MessageTag.fromMap(response.data);

    setState(() {
      final index = _allUserTags.indexWhere((t) => t.id == tag.id);
      if (index != -1) {
        _allUserTags[index] = newTag;

        final selectedIndex = _tempSelected.indexWhere((t) => t.id == tag.id);
        if (selectedIndex != -1) _tempSelected[selectedIndex] = newTag;
      }
    });
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);

    final response = await getTagsByRoomId(roomId: widget.roomId);
    if (!response.success) {
      print("Ошибка при получении тегов");
      setState(() => _isLoading = false);
      return;
    }

    final List<MessageTag> tags = (response.data as List?)
        ?.map((el) => MessageTag.fromMap(el as Map<String, dynamic>))
        .toList() ?? [];

    _allUserTags.addAll(tags);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 16, right: 16, top: 16,
      ),
      decoration: BoxDecoration(
        color: context.ui.containerColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildNewTagInput(),
          const SizedBox(height: 16),
          if (_isLoading)
            const CircularProgressIndicator()
          else
            _buildTagsList(),
          const SizedBox(height: 20),
          _buildDoneButton(),
        ],
      )),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Теги сообщения", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: context.ui.fontColorPrimary)),
        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
      ],
    );
  }

  Widget _buildNewTagInput() {
    return SizedBox(height: 48,child: IntrinsicHeight( // Магия здесь: делает высоту Row фиксированной по самому высокому элементу
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Заставляет детей растягиваться по высоте
        children: [
          // 1. Квадратик выбора цвета
          AspectRatio(
            aspectRatio: 1, // Гарантирует, что ширина всегда будет равна высоте (квадрат)
            child: GestureDetector(
              onTap: () => _showColorGridDialog(
                currentColor: _selectedColorValue,
                onColorSelected: (color) => setState(() => _selectedColorValue = color),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(_selectedColorValue),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: const Icon(Icons.palette_outlined, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 2. Поле ввода текста
          Expanded(
            child: TextField(
              controller: _newTagController,
              // Убираем лишние внешние отступы, если они мешают центровке
              decoration: InputDecoration(
                hintText: "Добавить новый тег...",
                // Чтобы TextField диктовал высоту, можно настроить padding внутри
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () async => await _handleAddNewTag(),
                ),
              ),
            ),
          ),
        ],
      ),
    ),);
  }

  Widget _buildTagsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200), // Ограничиваем высоту, чтобы окно не улетало вверх
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Wrap(
          spacing: 8,
          runSpacing: 4,
          children: _allUserTags.map((tag) {
            return TagChip(
              tag: tag,
              isSelected: _tempSelected.any((t) => t.id == tag.id),
              onSelected: (selected) {
                setState(() {
                  selected
                      ? _tempSelected.add(tag)
                      : _tempSelected.removeWhere((t) => t.id == tag.id);
                });
              },
              onLongPress: () => _showEditDeleteDialog(tag),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDoneButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: context.ui.primaryColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => Navigator.pop(context, _tempSelected),
        child: const Text("Применить", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}