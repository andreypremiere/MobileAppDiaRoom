import 'package:dia_room/models/canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'dart:io'; // Для работы с File
import 'package:image_picker/image_picker.dart';

class NewPublicPostScreen extends StatefulWidget {
  const NewPublicPostScreen({super.key});

  @override
  State<NewPublicPostScreen> createState() {
    return NewPublicPostState();
  }
}

class NewPublicPostState extends State<NewPublicPostScreen> {
  final TextEditingController _namePostController = TextEditingController();
  final List<BlockPost> _blocks = [];
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  late XFile _imagePrewiev;

  Future<void> _pickPrewiev() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    print('Путь к файлу: ${image.path}, Имя файла: ${image.name}');

    setState(() {
      _imagePrewiev = image;
    });
  }
  
  // Метод для вызова галереи
  Future<void> _pickImages() async {
    // pickMultiImage позволяет выбрать сразу несколько фото
    final List<XFile> images = await _picker.pickMultiImage();

    if (images.isNotEmpty) {
      setState(() {
        // Добавляем новые фото к уже выбранным
        _selectedImages.addAll(images);

        // Если хочешь ограничить до 20 штук, можно добавить проверку:
        // if (_selectedImages.length > 20) {
        //   _selectedImages = _selectedImages.sublist(0, 20);
        // }
      });
    }
  }

  // Метод для удаления фото из превью
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

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
        body: ListView(
          padding: EdgeInsets.all(8),
          children: [
            //
            // Название поста
            //
            TextField(
              controller: _namePostController,
              style: const TextStyle(
                fontFamily: 'SNPro',
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                // Текст-подсказка
                hintText: 'Название поста',
                hintStyle: const TextStyle(color: Colors.grey),
                // Внутренние отступы текста от краев рамки
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // Убираем стандартное подчеркивание
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFFFFF),
                  ), // Светло-серая рамка
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                ),
                // Рамка при нажатии (в фокусе)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB4B4B4),
                    width: 1.5,
                  ), // Делаем чуть темнее или толще
                ),
                // filled: true,
                // fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo_library),
              label: const Text('Выбрать фотографии'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC9C9C9),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true, // Важно! Позволяет GridView занимать только нужное место
                physics: const NeverScrollableScrollPhysics(), // Отключаем скролл внутри сетки
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // Ровно 4 элемента в строке
                  crossAxisSpacing: 8, // Отступ между колонками
                  mainAxisSpacing: 8, // Отступ между строками
                  childAspectRatio: 1, // Делает ячейки квадратными
                ),
                itemCount: _selectedImages.length,
                itemBuilder: (context, index) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Само изображение
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedImages[index].path),
                          fit: BoxFit.cover, // Обрезает фото, чтобы оно заполнило квадрат
                        ),
                      ),
                      // Кнопка удаления (крестик) в правом верхнем углу
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => {_removeImage(index)},
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

            // Динамические блоки
            // Троеточие (...) "распаковывает" список блоков прямо сюда
            ..._blocks.map((block) => _buildBlock(block)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BlockPost block) {
    return Container();
  }
}
