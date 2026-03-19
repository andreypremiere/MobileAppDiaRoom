import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Для работы с File
import 'package:image_picker/image_picker.dart';

import '../components/new_public_post/block_toolbar.dart';
import '../components/new_public_post/post_block_widget.dart';
import '../models/enums/post_types.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_post.dart';
import '../models/post_creator/block_text.dart';

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

  void _focusBlock(int index) {
    if (_focusedIndex == index) return; // ← защита от лишних rebuild

    setState(() {
      _focusedIndex = index;
    });

    final block = _blocks[index];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (block is BlockText) {
        block.focusNode.requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void _addBlock(BlockPostType type) {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();

      if (type == BlockPostType.text) {
        _addTextBlock();
      } else if (type == BlockPostType.photos) {
        _addPhotosBlock();
      }
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
    final newController = TextEditingController();
    final newBlock = BlockText(controller: newController);

    setState(() {
      _blocks.add(newBlock);
      _focusedIndex = _blocks.length - 1;
    });

    // Только один addPostFrameCallback и без лишнего setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newBlock.focusNode.requestFocus();
    });
  }

  void _addPhotosBlock() {
    final newBlock = BlockPhotos();

    setState(() {
      _blocks.add(newBlock);
      _focusedIndex = _blocks.length - 1;
    });

    // FocusScope.of(context).unfocus();

    // Для фото сразу убираем клавиатуру БЕЗ лишнего setState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('Объект в фокусе до: ${FocusManager.instance.primaryFocus}');
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _focusedIndex = null;
        });
        print("Фокус снят, индекс сброшен");
        print("Build triggered with index: $_focusedIndex");
        print('Объект в фокусе после: ${FocusManager.instance.primaryFocus}');
      },
      behavior: HitTestBehavior.opaque,
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
                      // onOpened: () {
                      //   // Жестко снимаем фокус до открытия меню
                      //   FocusManager.instance.primaryFocus?.unfocus();
                      // },
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
                        return PostBlockWrapper(
                          key: ValueKey(_blocks[index]),
                          block: _blocks[index],
                          isFocused: index == _focusedIndex,
                          onFocus: () => _focusBlock(index),
                          onMoveUp: () => _moveUpBlock(index),
                          onMoveDown: () => _moveDownBlock(index),
                          onDelete: () => _deleteBlock(index),
                          onChanged: () =>
                              setState(() {}), // Просто перерисовываем экран
                        );
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
                        child: PostToolbar(
                          block: _blocks[_focusedIndex!],
                          onChanged: () {
                            // Когда в тулбаре что-то нажмут, сработает этот setState
                            setState(() {});
                          },
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
