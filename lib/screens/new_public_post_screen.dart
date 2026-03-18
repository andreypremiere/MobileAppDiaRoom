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
      }
    });
  }

  void _addTextBlock() {
    FocusScope.of(context).unfocus();
    TextEditingController newController = TextEditingController();
    BlockText newTextBlock = BlockText(controller: newController);
    _blocks.add(newTextBlock);
    _focusedIndex = _blocks.length - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newTextBlock.focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
          _focusedIndex = null;
        }
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
                ],
              ),
      ),
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
                        // TODO: Логика перемещения блока вниз
                      },
                    ),
                    _buildActionButton(
                      iconData: Icons.arrow_circle_up,
                      iconColor: const Color(0xFF797979),
                      onPressed: () {
                        print('Блок $index вверх');
                        // TODO: Логика перемещения блока вверх
                      },
                    ),
                    _buildActionButton(
                      iconData: Icons.delete_outline,
                      iconColor: Colors.redAccent, // Красный для удаления
                      onPressed: () {
                        print('Удалить блок $index');
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

class BlockPost {
  final BlockPostType type;

  BlockPost({required this.type});
}

class BlockText extends BlockPost {
  TextEditingController controller;
  final FocusNode focusNode;
  Map<String, dynamic> metadata;

  BlockText({required this.controller, this.metadata = const {}})
    : focusNode = FocusNode(),
      super(type: BlockPostType.text);

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}
