import 'package:dia_room/components/room_screen/app_dialogs.dart';
import 'package:dia_room/configuration/constants.dart';
import 'package:dia_room/models/post_creator/block_video.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../components/general/app_back_button.dart';
import '../../components/new_public_post/app_bar_button.dart';
import '../../components/info_dialog_component.dart';
import '../../components/new_public_post/block_toolbar.dart';
import '../../components/new_public_post/post_block_widget.dart';
import '../../models/enums/block_type.dart';
import '../../models/enums/method_view_photo.dart';
import '../../models/post_creator/block_photos.dart';
import '../../models/post_creator/block_post.dart';
import '../../models/post_creator/block_text.dart';
import '../../models/post_creator/post_draft.dart';
import '../../utils/draft_provider.dart';

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

    if (mounted) {
      setState(() {
        _focusedIndex = index;
      });
    }

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
        return block.isEmpty();
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

    if (postDraft.blocks.length >= limitGeneralCountBlockInPost) {
      if (context.mounted) {
        AppInfoDialog.show(context, "Можно добавить только $limitGeneralCountBlockInPost блоков.");
      }
      return;
    }

    if (type == BlockType.text) {
      _addTextBlock();
    } else if (type == BlockType.photos) {
      int countPhotoBlock = 0;
      for (var block in postDraft.blocks) {
        if (block.type == BlockType.photos) {
          countPhotoBlock += 1;
        }
      }

      if (countPhotoBlock >= limitCountPhotoBlockInPost) {
        AppInfoDialog.show(context, "Пока что можно добавить только $limitCountPhotoBlockInPost блока фотографий.");
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

      if (countVideoBlock >= limitCountVideoBlockInPost) {
        AppInfoDialog.show(context, "Пока что можно добавить только $limitCountVideoBlockInPost блока видео.");
        return;
      }

      _addVideoBlock();
    }
  }

  /// Изменение порядка: перемещение блока вверх по списку
  void _moveUpBlock(int targetIndex) {
    if (mounted) {
      setState(() {
        if (targetIndex == 0) return;
        BlockPost targetValue = postDraft.blocks[targetIndex - 1];
        postDraft.blocks[targetIndex - 1] = postDraft.blocks[targetIndex];
        postDraft.blocks[targetIndex] = targetValue;
        _focusBlock(targetIndex - 1);
      });
    }
  }

  /// Изменение порядка: перемещение блока вниз по списку
  void _moveDownBlock(int targetIndex) {
    if (mounted) {
      setState(() {
        if (targetIndex >= postDraft.blocks.length - 1) return;
        BlockPost targetValue = postDraft.blocks[targetIndex + 1];
        postDraft.blocks[targetIndex + 1] = postDraft.blocks[targetIndex];
        postDraft.blocks[targetIndex] = targetValue;
        _focusBlock(targetIndex + 1);
      });
    }
  }

  /// Удаление блока из черновика
  Future<void> _deleteBlock(int index) async {
    bool? confirm;
    if (mounted) {
      confirm = await AppDialogs.showConfirmDialog(context,
          text: "Вы уверены, что хотите удалить блок?", cancelText: "Отмена", confirmText: "Подтвердить");
    }

    if (confirm == null || !confirm) return;

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
    final newBlock = BlockTextCreating();

    if (mounted) {
      setState(() {
        postDraft.blocks.add(newBlock);
        _focusedIndex = postDraft.blocks.length - 1;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newBlock.focusNode.requestFocus();
    });
  }

  void _addPhotosBlock() {
    final newBlock = BlockPhotosCreating(listPhoto: [], methodView: MethodViewPhoto.tiles);
    if (mounted) {
      setState(() {
        postDraft.blocks.add(newBlock);
        _focusedIndex = postDraft.blocks.length - 1;
      });
    }
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
    if (mounted) {
      setState(() {
        postDraft.blocks.add(newBlock);
        _focusedIndex = postDraft.blocks.length - 1;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  Future<void> handleBack() async {
    final result = await AppDialogs.showConfirmDialog(context, text: "Вы уверены, что хотите покинуть страницу? Данные будут утеряны.", cancelText: "Отмена", confirmText: "Выйти");
    if (result != null && result) {
      if (mounted) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      /// Глобальное снятие фокуса и выделения блока при нажатии на пустую область
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        if (mounted) {
          setState(() {
            _focusedIndex = null;
          });
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        extendBody: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: context.ui.appBarColor,
            leading: AppBackButton(onPressed: handleBack,),
            title: Text(
              'Создание публикации',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            actions: [
              AppBarButton(text: "Далее", onPressed: () {
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
              },),
              SizedBox(width: 6),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          bottom: true,
          child: postDraft.blocks.isEmpty
            /// Плейсхолдер для пустого экрана: кнопка добавления первого блока
            ? Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Добавьте первое значение',
                      style: TextStyle(fontFamily: 'SNPro', fontSize: 24, color: context.ui.appBarColor, fontWeight: FontWeight.w600),
                    ),
                    PopupMenuButton<BlockType>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: context.ui.containerColor,
                      elevation: 5,
                      offset: const Offset(10, 10),
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: context.ui.toolbarContainerColor,
                          disabledForegroundColor: context.ui.fontColorLight,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add_rounded, size: 40),
                      ),
                      onSelected: (value) => _addBlock(value),
                      itemBuilder: (context) => BlockType.values
                          .where((type) => type != BlockType.videos)
                          .map(
                            (type) => PopupMenuItem<BlockType>(
                              height: 40,
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type.icon,
                                    color: context.ui.fontColorPrimary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: context.ui.fontColorPrimary,
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
                      itemCount: postDraft.blocks.length + 1,
                      itemBuilder: (context, index) {
                        if (index == postDraft.blocks.length) {
                          return const SizedBox(height: 80);
                        }

                        /// Обертка блока, отвечающая за его отрисовку и контекстное меню действий
                        return PostBlockWrapper(
                          key: ValueKey(postDraft.blocks[index]),
                          block: postDraft.blocks[index],
                          isFocused: index == _focusedIndex,
                          onFocus: () => _focusBlock(index),
                          onMoveUp: () => _moveUpBlock(index),
                          onMoveDown: () => _moveDownBlock(index),
                          onDelete: () async => await _deleteBlock(index),
                          onChanged: () {
                            if (mounted) {
                              setState(() {});
                            }
                          } ,
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
                      color: context.ui.containerColor,
                      elevation: 5,
                      offset: const Offset(10, 10),
                      child: ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: context.ui.toolbarContainerColor,
                          disabledForegroundColor: context.ui.fontColorLight,
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(8),
                        ),
                        child: Icon(Icons.add_rounded, size: 40),
                      ),
                      onSelected: (value) => _addBlock(value),
                      itemBuilder: (context) => BlockType.values
                          .where((type) => type != BlockType.videos)
                          .map(
                            (type) => PopupMenuItem<BlockType>(
                              height: 40,
                              value: type,
                              child: Row(
                                children: [
                                  Icon(
                                    type.icon,
                                    color: context.ui.fontColorPrimary,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    type.label,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: context.ui.fontColorPrimary,
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
                        (postDraft.blocks[_focusedIndex!] is BlockPhotosCreating))
                      Positioned(
                        bottom: 10,
                        left: 10,
                        child: Container(
                          height: 56,
                          // width: 240,
                          decoration: BoxDecoration(
                            color: context.ui.toolbarContainerColor,
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
      ),),
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
