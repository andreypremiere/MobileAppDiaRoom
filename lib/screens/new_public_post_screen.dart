import 'package:dia_room/models/canvas.dart';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
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
            : Text('В списке есть значения'),
      ),
    );
  }

  Widget _buildBlock(BlockPost block) {
    return Container();
  }
}
