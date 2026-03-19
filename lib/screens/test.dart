import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Добавьте в pubspec.yaml: image_picker: ^1.1.2

// ====================== МОДЕЛИ БЛОКОВ ======================
abstract class PostBlock {
  final String type;
  PostBlock({required this.type});
}

class TextPostBlock extends PostBlock {
  final TextEditingController controller;
  final FocusNode focusNode;
  String style; // 'header', 'subheader', 'text'

  TextPostBlock({
    String initialText = '',
    this.style = 'text',
  })  : controller = TextEditingController(text: initialText),
        focusNode = FocusNode(),
        super(type: 'text');
}

class PhotoPostBlock extends PostBlock {
  List<String> imagePaths; // пути к файлам
  bool isCarousel; // false = плитки (4 в ряд), true = карусель

  PhotoPostBlock({
    required this.imagePaths,
    this.isCarousel = false,
  }) : super(type: 'photo');
}

class VideoPostBlock extends PostBlock {
  List<String> videoPaths;
  bool isCarousel;

  VideoPostBlock({
    required this.videoPaths,
    this.isCarousel = false,
  }) : super(type: 'video');
}

// ====================== СТРАНИЦА ======================
class PostCreatorPage extends StatefulWidget {
  const PostCreatorPage({super.key});

  @override
  State<PostCreatorPage> createState() => _PostCreatorPageState();
}

class _PostCreatorPageState extends State<PostCreatorPage> {
  final List<PostBlock> blocks = [];
  int? focusedIndex;

  // ====================== ОБРАБОТЧИКИ ======================
  void _focusBlock(int index) {
    setState(() => focusedIndex = index);

    // Если блок текст — активируем поле и клавиатуру
    final block = blocks[index];
    if (block is TextPostBlock) {
      block.focusNode.requestFocus();
    } else {
      // Для фото/видео убираем фокус с клавиатуры
      FocusScope.of(context).unfocus();
    }
  }

  void _moveUp(int index) {
    if (index <= 0) return;
    setState(() {
      final temp = blocks[index];
      blocks[index] = blocks[index - 1];
      blocks[index - 1] = temp;
      focusedIndex = index - 1;
    });
  }

  void _moveDown(int index) {
    if (index >= blocks.length - 1) return;
    setState(() {
      final temp = blocks[index];
      blocks[index] = blocks[index + 1];
      blocks[index + 1] = temp;
      focusedIndex = index + 1;
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      final wasFocused = index == focusedIndex;
      blocks.removeAt(index);
      if (wasFocused) focusedIndex = null;
      if (focusedIndex != null && focusedIndex! >= index) {
        focusedIndex = focusedIndex! - 1;
      }
    });
  }

  // Добавление блоков
  Future<void> _addTextBlock() async {
    setState(() {
      blocks.add(TextPostBlock());
      focusedIndex = blocks.length - 1;
    });
  }

  Future<void> _addPhotoBlock() async {
    final picker = ImagePicker();
    final List<XFile>? files = await picker.pickMultiImage();
    if (files == null || files.isEmpty) return;

    setState(() {
      blocks.add(PhotoPostBlock(
        imagePaths: files.map((f) => f.path).toList(),
      ));
      focusedIndex = blocks.length - 1;
    });
  }

  Future<void> _addVideoBlock() async {
    final picker = ImagePicker();
    // Для простоты берём несколько видео по одному (можно расширить file_picker)
    final List<String> paths = [];
    for (int i = 0; i < 3; i++) { // демо — до 3 видео
      final XFile? file = await picker.pickVideo(source: ImageSource.gallery);
      if (file != null) paths.add(file.path);
    }
    if (paths.isEmpty) return;

    setState(() {
      blocks.add(VideoPostBlock(videoPaths: paths));
      focusedIndex = blocks.length - 1;
    });
  }

  // ====================== UI БЛОКА ======================
  Widget _buildBlock(int index) {
    final block = blocks[index];
    final isFocused = index == focusedIndex;

    // Основной контент блока (с отступом справа, если есть кнопки)
    final content = Container(
      width: double.infinity,
      margin: isFocused ? const EdgeInsets.only(right: 70) : null,
      decoration: isFocused
          ? BoxDecoration(
        border: Border.all(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.circular(8),
      )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === КОНТЕНТ БЛОКА ===
          _buildBlockContent(block, index),

          // === ПАНЕЛЬ ИНСТРУМЕНТОВ (только когда в фокусе) ===
          if (isFocused) _buildToolbar(block, index),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => _focusBlock(index),
      child: Stack(
        children: [
          content,
          // === КНОПКИ УПРАВЛЕНИЯ (сбоку) ===
          if (isFocused)
            Positioned(
              right: 8,
              top: 8,
              bottom: 8,
              child: Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _moveUp(index),
                      icon: const Icon(Icons.arrow_upward, size: 20),
                      tooltip: 'Вверх',
                    ),
                    IconButton(
                      onPressed: () => _moveDown(index),
                      icon: const Icon(Icons.arrow_downward, size: 20),
                      tooltip: 'Вниз',
                    ),
                    IconButton(
                      onPressed: () => _deleteBlock(index),
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      tooltip: 'Удалить',
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlockContent(PostBlock block, int index) {
    if (block is TextPostBlock) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          controller: block.controller,
          focusNode: block.focusNode,
          maxLines: null,
          style: _getTextStyle(block.style),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Введите текст...',
          ),
          onTap: () => _focusBlock(index), // повторный фокус при тапе
        ),
      );
    }

    if (block is PhotoPostBlock) {
      return _buildMediaGridOrCarousel(
        paths: block.imagePaths,
        isCarousel: block.isCarousel,
        isVideo: false,
      );
    }

    if (block is VideoPostBlock) {
      return _buildMediaGridOrCarousel(
        paths: block.videoPaths,
        isCarousel: block.isCarousel,
        isVideo: true,
      );
    }

    return const SizedBox();
  }

  TextStyle _getTextStyle(String style) {
    switch (style) {
      case 'header':
        return const TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      case 'subheader':
        return const TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
      default:
        return const TextStyle(fontSize: 16);
    }
  }

  // Общий виджет для фото и видео (4 в ряд или карусель)
  Widget _buildMediaGridOrCarousel({
    required List<String> paths,
    required bool isCarousel,
    required bool isVideo,
  }) {
    if (paths.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('Нет медиа', style: TextStyle(color: Colors.grey)),
      );
    }

    if (isCarousel) {
      return SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: paths.length,
          itemBuilder: (context, i) {
            return Container(
              width: 120,
              margin: const EdgeInsets.only(right: 8),
              child: isVideo
                  ? Container(
                color: Colors.black12,
                child: const Center(child: Icon(Icons.video_library, size: 40)),
              )
                  : Image.file(File(paths[i]), fit: BoxFit.cover),
            );
          },
        ),
      );
    }

    // Плитки — 4 в ряд
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: paths.length,
      itemBuilder: (context, i) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: isVideo
              ? Container(
            color: Colors.black12,
            child: const Center(child: Icon(Icons.video_library, size: 32)),
          )
              : Image.file(File(paths[i]), fit: BoxFit.cover),
        );
      },
    );
  }

  Widget _buildToolbar(PostBlock block, int index) {
    if (block is TextPostBlock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.grey[100],
        child: Row(
          children: [
            _toolbarButton('H1', block.style == 'header', () {
              setState(() => block.style = 'header');
            }),
            _toolbarButton('H2', block.style == 'subheader', () {
              setState(() => block.style = 'subheader');
            }),
            _toolbarButton('Текст', block.style == 'text', () {
              setState(() => block.style = 'text');
            }),
          ],
        ),
      );
    }

    // === Фото и Видео (отдельные if, чтобы работала type promotion) ===
    if (block is PhotoPostBlock) {
      return _buildMediaToolbar(
        isCarousel: block.isCarousel,
        onChange: (value) => setState(() => block.isCarousel = value),
      );
    }

    if (block is VideoPostBlock) {
      return _buildMediaToolbar(
        isCarousel: block.isCarousel,
        onChange: (value) => setState(() => block.isCarousel = value),
      );
    }

    return const SizedBox();
  }

  // === Вспомогательный виджет (чтобы не дублировать код) ===
  Widget _buildMediaToolbar({
    required bool isCarousel,
    required Function(bool) onChange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[100],
      child: Row(
        children: [
          _toolbarButton('Карусель', isCarousel, () => onChange(true)),
          _toolbarButton('Плитки', !isCarousel, () => onChange(false)),
        ],
      ),
    );
  }

  Widget _toolbarButton(String text, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAddPopupMenu() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Center(
        child: PopupMenuButton<String>(
          // Иконка может быть любой — плюс, три точки, more_vert и т.д.
          icon: const Icon(
            Icons.add_circle,
            size: 48,
            color: Colors.blue,
          ),
          tooltip: 'Добавить блок',
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 8,
          offset: const Offset(0, -140), // чтобы меню поднималось вверх (удобнее)
          onSelected: (value) {
            switch (value) {
              case 'text':
                _addTextBlock();
                break;
              case 'photo':
                _addPhotoBlock();
                break;
              case 'video':
                _addVideoBlock();
                break;
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(
              value: 'text',
              child: ListTile(
                leading: Icon(Icons.text_fields, color: Colors.blue),
                title: Text('Текст'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'photo',
              child: ListTile(
                leading: Icon(Icons.photo_library, color: Colors.green),
                title: Text('Фото'),
              ),
            ),
            const PopupMenuDivider(),
            const PopupMenuItem<String>(
              value: 'video',
              child: ListTile(
                leading: Icon(Icons.video_library, color: Colors.purple),
                title: Text('Видео'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== BUILD ======================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать пост'),
        actions: [
          IconButton(
            onPressed: () {
              // Здесь можно собрать все блоки и отправить на сервер
              final postData = blocks.map((b) {
                if (b is TextPostBlock) return {'type': 'text', 'text': b.controller.text, 'style': b.style};
                if (b is PhotoPostBlock) return {'type': 'photo', 'paths': b.imagePaths, 'carousel': b.isCarousel};
                if (b is VideoPostBlock) return {'type': 'video', 'paths': b.videoPaths, 'carousel': b.isCarousel};
                return {};
              }).toList();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Пост сохранён: ${postData.length} блоков')));
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: blocks.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Нажмите на + внизу, чтобы начать',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 80), // запас снизу
        itemCount: blocks.length + 1,
        itemBuilder: (context, index) {
          if (index < blocks.length) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBlock(index),
            );
          }

          // Последний элемент — PopupMenuButton для добавления
          return _buildAddPopupMenu();
        },
      ),
    );
  }

  @override
  void dispose() {
    // Освобождаем ресурсы
    for (final block in blocks) {
      if (block is TextPostBlock) {
        block.controller.dispose();
        block.focusNode.dispose();
      }
    }
    super.dispose();
  }
}