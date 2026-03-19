import 'package:dia_room/models/canvas.dart';
import 'package:dia_room/screens/test.dart';

// import 'package:dia_room/screens/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Для работы с File
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class NewPublicPostScreen extends StatefulWidget {
  const NewPublicPostScreen({super.key});

  @override
  State<NewPublicPostScreen> createState() {
    return NewPublicPostState();
  }
}

class NewPublicPostState extends State<NewPublicPostScreen> {
  final List<BlockPost> _blocks = [];
  final ImagePicker _picker = ImagePicker();
  int? _focusedIndex;

  void _addBlock(BlockPostType type) {
    setState(() {
      if (type == BlockPostType.text) {
        _addTextBlock();
      } else if (type == BlockPostType.photos) {
        _addPhotosBlock();
      }
    });
  }

  void _moveUpBlock(int targetIndex) {
    setState(() {
      if (targetIndex == 0) return;
      BlockPost targetValue = _blocks[targetIndex - 1];
      _blocks[targetIndex - 1] = _blocks[targetIndex];
      _blocks[targetIndex] = targetValue;
      _focusBlock(targetIndex - 1);
    });
  }

  void _moveDownBlock(int targetIndex) {
    setState(() {
      if (targetIndex >= _blocks.length - 1) return;
      BlockPost targetValue = _blocks[targetIndex + 1];
      _blocks[targetIndex + 1] = _blocks[targetIndex];
      _blocks[targetIndex] = targetValue;
      _focusBlock(targetIndex + 1);
    });
  }

  void _deleteBlock(int index) {
    setState(() {
      _blocks.removeAt(index);
      _focusedIndex = null;
    });
  }

  void _addTextBlock() {
    TextEditingController newController = TextEditingController();
    BlockText newTextBlock = BlockText(controller: newController);

    _blocks.add(newTextBlock);
    _focusedIndex = _blocks.length - 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusBlock(_focusedIndex!);
    });
  }

  void _addPhotosBlock() {
    BlockPhotos newPhotosBlock = BlockPhotos();

    _blocks.add(newPhotosBlock);
    _focusedIndex = _blocks.length - 1;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusBlock(_focusedIndex!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        // Снимаем системный фокус (клавиатуру)
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }

        // Снимаем выделение с вашего блока (синюю рамку)
        setState(() {
          _focusedIndex = null;
        });
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Color(0xFFB4B4B4),
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: SvgPicture.asset(
                'assets/icons/button_back.svg',
                width: 32,
                height: 32,
              ),
            ),
            title: Text(
              'Создание поста',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'SNPro',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  print('Отправлен дальше');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  backgroundColor: Color(0xFFC9C9C9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Чем больше число, тем круглее
                    // Можно также добавить рамку самой кнопке:
                    // side: BorderSide(color: Colors.black, width: 1),
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
        body: _blocks.isEmpty
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
                    PopupMenuButton<BlockPostType>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Цвет фона меню
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      // Тень (делаем мягкую)
                      elevation: 5,
                      // Сдвигаем меню на 50 пикселей вниз, чтобы не перекрывать кнопку "+"
                      offset: const Offset(10, 10),
                      // Твоя кнопка теперь просто открывает меню
                      child: ElevatedButton(
                        onPressed: null,
                        // Ставим null, так как за нажатие теперь отвечает PopupMenuButton
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: const Color(0xFF525252),
                          // Твой цвет
                          disabledForegroundColor: Colors.white,
                          shape: const CircleBorder(),
                          // Делаем кнопку круглой
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),

                      // Что делать при выборе пункта
                      onSelected: (BlockPostType value) {
                        print("Выбрано: $value");
                        // Здесь вызываешь свои функции: _addText(), _addPhoto() и т.д.
                        _addBlock(value);
                      },

                      // Сами пункты меню
                      itemBuilder: (context) =>
                          BlockPostType.values.map((type) {
                            return PopupMenuItem<BlockPostType>(
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
                                  // Отступ между иконкой и текстом
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
                            );
                          }).toList(),
                    ),
                  ],
                ),
              )
            : Stack(
                children: [
                  Positioned.fill(
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                      itemCount: _blocks.length,
                      itemBuilder: (context, index) {
                        return _buildBlock(index);
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: PopupMenuButton<BlockPostType>(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      // Цвет фона меню
                      color: Colors.white,
                      padding: EdgeInsets.zero,
                      // Тень (делаем мягкую)
                      elevation: 5,
                      // Сдвигаем меню на 50 пикселей вниз, чтобы не перекрывать кнопку "+"
                      offset: const Offset(10, 10),
                      // Твоя кнопка теперь просто открывает меню
                      child: ElevatedButton(
                        onPressed: null,
                        // Ставим null, так как за нажатие теперь отвечает PopupMenuButton
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: const Color(0xFF525252),
                          // Твой цвет
                          disabledForegroundColor: Colors.white,
                          shape: const CircleBorder(),
                          // Делаем кнопку круглой
                          padding: const EdgeInsets.all(8),
                        ),
                        child: const Icon(Icons.add, size: 40),
                      ),

                      // Что делать при выборе пункта
                      onSelected: (BlockPostType value) {
                        print("Выбрано: $value");
                        // Здесь вызываешь свои функции: _addText(), _addPhoto() и т.д.
                        _addBlock(value);
                      },

                      // Сами пункты меню
                      itemBuilder: (context) =>
                          BlockPostType.values.map((type) {
                            return PopupMenuItem<BlockPostType>(
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
                                  // Отступ между иконкой и текстом
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
                            );
                          }).toList(),
                    ),
                  ),
                  if (_focusedIndex != null)
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
                        child: _buildToolbar(),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildToolbar() {
    BlockPostType type = _blocks[_focusedIndex!].type;

    SingleChildScrollView listView(Row content) => SingleChildScrollView(
      // clipBehavior: Clip.none,
      scrollDirection: Axis.horizontal,
      child: Padding(padding: EdgeInsets.all(6), child: content),
    );

    if (type == BlockPostType.text) {
      return listView(_buildTextToolbar());
    }
    if (type == BlockPostType.photos) {
      return listView(_buildPhotoToolbar());
    }

    return Container();
  }

  Row _buildPhotoToolbar() {
    BlockPhotos block = _blocks[_focusedIndex!] as BlockPhotos;
    MethodViewPhoto currentType = block.methodView;

    return Row(
      children: [
        PopupMenuButton<MethodViewPhoto>(
          // Применяем твою стилизацию из шаблона
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 5,
          offset: const Offset(0, 45), // Сдвиг вниз, чтобы не перекрывать кнопку

          // Внешний вид кнопки
          child: Container(
            width: 120, // Фиксированная ширина кнопки
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF525252), // Твой темный цвет
              borderRadius: BorderRadius.circular(20), // Делаем кнопку овальной/круглой
            ),
            child: Center(
              child: Text(
                currentType.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Лишний текст превращается в "..."
                style: const TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // Белый текст на темном фоне
                ),
              ),
            ),
          ),

          onSelected: (MethodViewPhoto value) {
            setState(() {
              block.methodView = value;
            });
          },

          // Стилизация пунктов меню по твоему шаблону
          itemBuilder: (context) => MethodViewPhoto.values.map((type) {
            return PopupMenuItem<MethodViewPhoto>(
              height: 40,
              value: type,
              child: Row(
                children: [
                  // Иконка (если у TextType есть иконки, если нет — можно убрать или заменить на точку)
                  Icon(
                    type == TextType.header ? Icons.title : Icons.notes,
                    color: const Color(0xFF797979),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SNPro',
                      fontWeight: currentType == type ? FontWeight.w600 : FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Row _buildTextToolbar() {
    // Получаем текущий блок
    BlockText textBlock = _blocks[_focusedIndex!] as BlockText;
    TextType currentType = textBlock.textType;

    return Row(
      children: [
        PopupMenuButton<TextType>(
          // Применяем твою стилизацию из шаблона
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          padding: EdgeInsets.zero,
          elevation: 5,
          offset: const Offset(0, 45),
          // Сдвиг вниз, чтобы не перекрывать кнопку

          // Внешний вид кнопки
          child: Container(
            width: 120, // Фиксированная ширина кнопки
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF525252), // Твой темный цвет
              borderRadius: BorderRadius.circular(
                20,
              ), // Делаем кнопку овальной/круглой
            ),
            child: Center(
              child: Text(
                currentType.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                // Лишний текст превращается в "..."
                style: const TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white, // Белый текст на темном фоне
                ),
              ),
            ),
          ),

          onSelected: (TextType value) {
            setState(() {
              textBlock.textType = value;
              // Логика метаданных
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
            });
          },

          // Стилизация пунктов меню по твоему шаблону
          itemBuilder: (context) => TextType.values.map((type) {
            return PopupMenuItem<TextType>(
              height: 40,
              value: type,
              child: Row(
                children: [
                  // Иконка (если у TextType есть иконки, если нет — можно убрать или заменить на точку)
                  Icon(
                    type == TextType.header ? Icons.title : Icons.notes,
                    color: const Color(0xFF797979),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'SNPro',
                      fontWeight: currentType == type
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }



  void _focusBlock(int index) {
    setState(() {
      _focusedIndex = index;
    });

    final block = _blocks[index];
    if (block is BlockText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        block.focusNode.requestFocus();
      });
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  Widget _buildBlock(int index) {
    final block = _blocks[index];
    final isFocused = index == _focusedIndex;

    // 2. Вспомогательная функция для создания стилизованной кнопки
    Widget _buildActionButton({
      required IconData iconData,
      required Color iconColor,
      required VoidCallback onPressed,
    }) {
      return Container(
        margin: const EdgeInsets.only(left: 8),
        // Отступ между кнопками
        width: 36,
        // Фиксированный размер круга
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white, // Белый фон
          shape: BoxShape.circle, // Круглая подложка
          boxShadow: [
            // Мягкая тень, чтобы кнопка выделялась на фоне
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          padding: EdgeInsets.zero, // Убираем отступы внутри IconButton
          iconSize: 20, // Размер самой иконки
          onPressed: onPressed,
          icon: Icon(iconData, color: iconColor),
        ),
      );
    }

    final content = Container(
      // margin: EdgeInsets.only(bottom: 6),
      width: double.infinity,
      // height: 60,
      decoration: isFocused
          ? BoxDecoration(
              border: Border.all(color: Colors.blue, width: 1),
              borderRadius: BorderRadius.circular(8),
            )
          : BoxDecoration(
              border: Border.all(color: Color(0xFFC9C9C9), width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
      child: _buildBlockContent(block, index),
    );

    return GestureDetector(
      key: ValueKey(block),
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusBlock(index),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        // Отступ всего блока от следующего
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          // Выравниваем Row по правому краю
          children: [
            // Сам блок (Текст/Фото)
            content,
            // Панель управления (иконки под блоком справа)
            if (isFocused) // Показываем только если блок в фокусе
              Container(
                margin: const EdgeInsets.only(top: 2, right: 4),
                // Отступы панели от блока
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // Берем место только под иконки
                  children: [
                    _buildActionButton(
                      iconData: Icons.arrow_circle_down,
                      iconColor: const Color(0xFF797979),
                      onPressed: () {
                        print('Блок $index вниз');
                        _moveDownBlock(index);
                      },
                    ),
                    _buildActionButton(
                      iconData: Icons.arrow_circle_up,
                      iconColor: const Color(0xFF797979),
                      onPressed: () {
                        print('Блок $index вверх');
                        _moveUpBlock(index);
                      },
                    ),
                    _buildActionButton(
                      iconData: Icons.delete_outline,
                      iconColor: Colors.redAccent, // Красный для удаления
                      onPressed: () {
                        print('Удалить блок $index');
                        _deleteBlock(index);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockContent(BlockPost block, int index) {
    if (block.type == BlockPostType.text) {
      return _buildTextBlock(block as BlockText, index);
    }
    if (block.type == BlockPostType.photos) {
      return _buildPhotosBlock(block as BlockPhotos, index);
    }
    return SizedBox();
  }

  FontWeight _getFontWeight(int value) {
    switch (value) {
      case 400:
        return FontWeight.w400;
      case 600:
        return FontWeight.w600;
      case 800:
        return FontWeight.w800;
      default:
        return FontWeight.w400;
    }
  }

  Widget _buildPhotosBlock(BlockPhotos block, int index) {
    const double blockHeight = 70;
    const double borderRadius = 8;

    // Вспомогательный виджет для рамки (кнопка добавления или контейнер для фото)
    Widget _buildDecoratedBox({required Widget child, Color? backgroundColor}) {
      return Container(
        width: blockHeight,
        // Делаем квадратным
        height: blockHeight,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: const Color(0xFFC9C9C9), width: 1),
        ),
        // ClipRRect нужен, чтобы изображение не вылезало за скругленные углы рамки
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 1),
          child: child,
        ),
      );
    }

    Future<void> _pickImagesForBlock(BlockPhotos block) async {
      try {
        // image_picker позволяет выбрать несколько фото за раз
        final List<XFile> pickedFiles = await _picker.pickMultiImage(
          // imageQuality: 50,
        );

        if (pickedFiles.isNotEmpty) {
          setState(() {
            // Добавляем пути к новым файлам в существующий список блока
            block.paths.addAll(pickedFiles.map((file) => file.path));
          });
          print(
            'Добавлено ${pickedFiles.length} фото. Всего в блоке: ${block.paths.length}',
          );
        }
      } catch (e) {
        print("Ошибка при выборе изображений: $e");
        // Здесь можно показать пользователю SnackBar с ошибкой
      }
    }

    return Container(
      // Внутренние отступы самого блока, чтобы контент не прилипал к синей/серой рамке фокуса
      padding: const EdgeInsets.all(8),
      // Ограничиваем высоту всего блока
      height: blockHeight + 32, // Высота контента + padding
      child: SingleChildScrollView(
        // clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal, // Прокрутка по горизонтали
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // 1. КНОПКА ДОБАВЛЕНИЯ (всегда первая)
              GestureDetector(
                onTap: () {
                  print('Нажата кнопка добавления фото в блок $index');
                  _pickImagesForBlock(
                    block,
                  ); // Вызываем метод выбора фото (см. ниже)
                },
                child: _buildDecoratedBox(
                  backgroundColor: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF797979),
                    size: 24,
                  ),
                ),
              ),

              // Добавляем разделитель между кнопкой и первым фото, если фото есть
              if (block.paths.isNotEmpty) const SizedBox(width: 8),

              // 2. СПИСОК ВЫБРАННЫХ ФОТО
              // Используем .asMap().entries.map, чтобы получить и путь, и индекс (для удаления)
              ...block.paths.asMap().entries.map((entry) {
                final int photoIndex = entry.key;
                final String path = entry.value;

                return Padding(
                  // Отступ между фотографиями
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    // Чтобы кнопка удаления могла вылезать за пределы
                    children: [
                      // Сама миниатюра фото
                      _buildDecoratedBox(
                        child: Image.file(
                          File(path),
                          fit: BoxFit
                              .cover, // Растягиваем фото, чтобы заполнить квадрат
                        ),
                      ),

                      // КНОПКА УДАЛЕНИЯ ОДНОГО ФОТО (маленький крестик сверху справа)
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              block.paths.removeAt(
                                photoIndex,
                              ); // Удаляем фото из списка
                            });
                            print('Удалено фото $photoIndex из блока $index');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD3D3D3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Color(0xFF2A2A2A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextBlock(BlockText block, int index) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      // Обрезаем TextField по краям контейнера, чтобы он не "вылезал" за скругления
      clipBehavior: Clip.antiAlias,
      child: TextField(
        controller: block.controller,
        onTap: () {
          _focusBlock(index); // Теперь при клике в поле ввода индекс обновится
        },
        focusNode: block.focusNode,
        autofocus: false,
        minLines: 3,
        maxLines: null,
        // Расширяется при вводе

        // Настройка шрифта
        style: TextStyle(
          fontFamily: 'SNPro',
          // Твой шрифт из проекта
          fontSize: block.metadata['size']?.toDouble() ?? 16,
          fontWeight: _getFontWeight(block.metadata['weight'] ?? 0),
          // Regular вес
          color: Colors.black87,
        ),

        decoration: InputDecoration(
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: 'Введите текст...',
          hintStyle: TextStyle(color: Colors.grey.shade400),

          // Внутренние отступы текста от рамки
          contentPadding: const EdgeInsets.all(16),

          // // Настройка "тусклой" рамки (когда поле не в фокусе)
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   // borderSide: BorderSide(
          //   //   color: Colors.grey.shade300, // Тускло-серый цвет
          //   //   width: 1,
          //   // ),
          // ),
          //
          // // Настройка рамки при нажатии (фокусе)
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   // borderSide: const BorderSide(
          //   //   color: Color(0xFF525252), // Твой основной серый цвет
          //   //   width: 1.5,
          //   // ),
          // ),

          // Заливка фона внутри рамки (опционально)
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}

enum TextType {
  header('Заголовок'),
  subtitle('Подзаголовок'),
  text('Текст');

  final String label;

  const TextType(this.label);
}

enum MethodViewPhoto {
  tiles('Плитки'),
  slider('Слайдер');

  final String label;

  const MethodViewPhoto(this.label);
}

class BlockPost {
  final BlockPostType type;

  BlockPost({required this.type});
}

class BlockText extends BlockPost {
  TextEditingController controller;
  final FocusNode focusNode;
  TextType textType;
  Map<String, dynamic> metadata;

  BlockText({
    required this.controller,
    Map<String, dynamic>? metadata,
    this.textType = TextType.text,
  }) : focusNode = FocusNode(), metadata = metadata ?? {},
       super(type: BlockPostType.text);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class BlockPhotos extends BlockPost {
  List<String> paths;
  MethodViewPhoto methodView;


  BlockPhotos({List<String>? paths, this.methodView = MethodViewPhoto.tiles})
    : paths = paths ?? [],
      super(type: BlockPostType.photos);
}
