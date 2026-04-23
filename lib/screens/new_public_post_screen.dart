import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../components/info_dialog_component.dart';
import '../components/new_public_post/block_toolbar.dart';
import '../components/new_public_post/post_block_widget.dart';
import '../models/enums/post_types.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_post.dart';
import '../models/post_creator/block_text.dart';
import '../models/post_creator/post_draft.dart';
import '../utils/draft_provider.dart';

class NewPublicPostScreen extends StatefulWidget {
  const NewPublicPostScreen({super.key});

  @override
  State<NewPublicPostScreen> createState() {
    return NewPublicPostState();
  }
}

class NewPublicPostState extends State<NewPublicPostScreen> {
  /// Объект черновика, содержащий все блоки и метаданные публикации
  final PostDraft postDraft = PostDraft();

  /// Индекс блока, который в данный момент редактируется пользователем
  int? _focusedIndex;

  /// Управление фокусом: активирует текстовое поле или снимает фокус с системы
  void _focusBlock(int index) {
    if (_focusedIndex == index) return;

    setState(() {
      _focusedIndex = index;
    });

    final block = postDraft.blocks[index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (block is BlockTextCreating) {
        block.focusNode.requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    });
  }

  /// Удаляет из списка блоки, которые не содержат контента.
  void removeEmptyBlocks() {
    postDraft.blocks.removeWhere((block) {
      if (block is BlockTextCreating) {
        return block.controller.text.trim().isEmpty;
      }
      if (block is BlockPhotosCreating) {
        return block.isEmpty();
      }
      if (block is BlockVideoCreating) {
        return block.isEmpty();
      }
      return false;
    });
  }

  /// Общий метод добавления нового контентного блока
  void _addBlock(BlockType type) {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

    if (type == BlockType.text) {
      _addTextBlock();
    } else if (type == BlockType.photos) {
      int countPhotoBlock = 0;
      for (var block in postDraft.blocks) {
        if (block.type == BlockType.photos) {
          countPhotoBlock += 1;
        }
      }

      if (countPhotoBlock >= 4) {
        AppInfoDialog.show(context, "Пока что можно добавить только 4 блока фотографий :(");
        return;
      }

      _addPhotosBlock();

    } else if (type == BlockType.videos) {
      int countVideoBlock = 0;
      for (var block in postDraft.blocks) {
        if (block.type == BlockType.photos) {
          countVideoBlock += 1;
        }
      }

      if (countVideoBlock >= 4) {
        AppInfoDialog.show(context, "Пока что можно добавить только 4 блока видео :(");
        return;
      }

      _addVideoBlock();
    }
  }

  /// Изменение порядка: перемещение блока вверх по списку
  void _moveUpBlock(int targetIndex) {
    setState(() {
      if (targetIndex == 0) return;
      BlockPost targetValue = postDraft.blocks[targetIndex - 1];
      postDraft.blocks[targetIndex - 1] = postDraft.blocks[targetIndex];
      postDraft.blocks[targetIndex] = targetValue;
      _focusBlock(targetIndex - 1);
    });
  }

  /// Изменение порядка: перемещение блока вниз по списку
  void _moveDownBlock(int targetIndex) {
    setState(() {
      if (targetIndex >= postDraft.blocks.length - 1) return;
      BlockPost targetValue = postDraft.blocks[targetIndex + 1];
      postDraft.blocks[targetIndex + 1] = postDraft.blocks[targetIndex];
      postDraft.blocks[targetIndex] = targetValue;
      _focusBlock(targetIndex + 1);
    });
  }

  /// Удаление блока из черновика
  Future<void> _deleteBlock(int index) async {
    final block = postDraft.blocks[index];

    // 1. Проверяем тип блока и вызываем очистку ресурсов
    if (block is BlockPhotosCreating) {
      await block.deleteAllPhotos(); // Твой новый метод для очистки списка фото
    } else if (block is BlockVideoCreating) {
      await block.clearBlock(); // Метод для удаления видео и его превью
    }

    // 2. Только после удаления файлов убираем блок из UI
    if (mounted) {
      setState(() {
        postDraft.blocks.removeAt(index);
        _focusedIndex = null;
      });
    }
  }

  /// Специфичные методы инициализации блоков (Текст, Фото, Видео)
  void _addTextBlock() {
    final newController = TextEditingController();
    final newBlock = BlockTextCreating(controller: newController);

    setState(() {
      postDraft.blocks.add(newBlock);
      _focusedIndex = postDraft.blocks.length - 1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newBlock.focusNode.requestFocus();
    });
  }

  void _addPhotosBlock() {
    final newBlock = BlockPhotosCreating(listPhoto: [], methodView: MethodViewPhoto.tiles);
    setState(() {
      postDraft.blocks.add(newBlock);
      _focusedIndex = postDraft.blocks.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  void _addVideoBlock() {
    final newBlock = BlockVideoCreating(
        presignedUrl: '',
        previewPresignedUrl: '',
        localPath: '',
        publicUrl: '',
        previewLocalPath: '',
        fileName: '',
        previewPublicUrl: '',
        fileSize: 0
        );
    setState(() {
      postDraft.blocks.add(newBlock);
      _focusedIndex = postDraft.blocks.length - 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Глобальное снятие фокуса и выделения блока при нажатии на пустую область
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _focusedIndex = null;
        });
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Color(0xFFB4B4B4),
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: SvgPicture.asset(
                'assets/icons/button_back.svg',
                width: 32,
                height: 32,
              ),
            ),
            title: Text(
              'Создание публикации',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'SNPro',
              ),
            ),
            actions: [
              /// Кнопка перехода к предварительному просмотру и финальным настройкам
              ElevatedButton(
                onPressed: () {
                  if (postDraft.blocks.isEmpty) {
                    AppInfoDialog.show(
                      context,
                      "Ваш холст пустой! Добавьте содержимое",
                    );
                    return;
                  }
                  if (_isValidCanvas()) {
                    removeEmptyBlocks();
                    context.read<DraftProvider>().startNewDraft(postDraft);
                    context.push('/post_preview');
                  } else {
                    AppInfoDialog.show(
                      context,
                      "Все ваши блоки пустые :( ! Заполните их! ",
                    );
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  backgroundColor: Color(0xFFC9C9C9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Далее',
                  style: TextStyle(
                    fontFamily: 'SNPro',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
        body: postDraft.blocks.isEmpty
            /// Плейсхолдер для пустого экрана: кнопка добавления первого блока
            ? Container(
                color: Color(0xFFEAEAEA),
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Добавьте первое значение',
                      style: TextStyle(fontFamily: 'SNPro', fontSize: 24),
                    ),
                    PopupMenuButton<BlockType>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      elevation: 5,
                      offset: const Offset(10, 10),
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: const Color(0xFF525252),
                          disabledForegroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),
                      onSelected: (value) => _addBlock(value),
                      itemBuilder: (context) => BlockType.values
                          .map(
                            (type) => PopupMenuItem<BlockType>(
                              height: 40,
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type.icon,
                                    color: const Color(0xFF797979),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              )
            /// Основной холст конструктора: список добавленных блоков
            : Stack(
                children: [
                  Positioned.fill(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      itemCount: postDraft.blocks.length,
                      itemBuilder: (context, index) {
                        /// Обертка блока, отвечающая за его отрисовку и контекстное меню действий
                        return PostBlockWrapper(
                          key: ValueKey(postDraft.blocks[index]),
                          block: postDraft.blocks[index],
                          isFocused: index == _focusedIndex,
                          onFocus: () => _focusBlock(index),
                          onMoveUp: () => _moveUpBlock(index),
                          onMoveDown: () => _moveDownBlock(index),
                          onDelete: () async => await _deleteBlock(index),
                          onChanged: () => setState(() {}),
                        );
                      },
                    ),
                  ),

                  /// Плавающая кнопка добавления контента (всегда доступна снизу справа)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: PopupMenuButton<BlockType>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.white,
                      elevation: 5,
                      offset: const Offset(10, 10),
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: const Color(0xFF525252),
                          disabledForegroundColor: Colors.white,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),
                      onSelected: (value) => _addBlock(value),
                      itemBuilder: (context) => BlockType.values
                          .map(
                            (type) => PopupMenuItem<BlockType>(
                              height: 40,
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type.icon,
                                    color: const Color(0xFF797979),
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type.label,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),

                  /// Панель инструментов
                  if (_focusedIndex != null)
                    /// Появляется только для определенного типа
                    if (_focusedIndex != null &&
                        (postDraft.blocks[_focusedIndex!] is BlockTextCreating ||
                            postDraft.blocks[_focusedIndex!] is BlockPhotosCreating))
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          height: 56,
                          width: 240,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: PostToolbar(
                            block: postDraft.blocks[_focusedIndex!],
                            onChanged: () => setState(() {}),
                          ),
                        ),
                      ),
                ],
              ),
      ),
    );
  }

  /// Проверка холста на наличие хотя бы одного заполненного блока
  bool _isValidCanvas() {
    final validatableBlocks = postDraft.blocks.whereType<Validatable>();

    for (final block in validatableBlocks) {
      if (!block.isEmpty()) return true;
    }
    return false;
  }
}
