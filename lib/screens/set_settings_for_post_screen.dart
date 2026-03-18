import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class SetSettingsForPostScreen extends StatefulWidget {
  const SetSettingsForPostScreen({super.key});

  @override
  State<SetSettingsForPostScreen> createState() {
    return _StateSetSettingsForPost();
  }

}

class _StateSetSettingsForPost extends State<SetSettingsForPostScreen> {
  final TextEditingController _namePostController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _previewImagePath;

  Future<void> _pickAndCropImage() async {
    // 1. Выбираем изображение
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      // 2. Сразу открываем редактор обрезки
      // await Future.delayed(const Duration(milliseconds: 1000));
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Обрежьте фото 16:9',
            toolbarColor: const Color(0xFFFF7878),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            // Начальное значение
            lockAspectRatio: true, // ЗАПРЕЩАЕМ менять соотношение сторон
          ),
          IOSUiSettings(
            title: 'Обрежьте фото 16:9',
            aspectRatioLockEnabled: true,
          ),
        ],
        aspectRatio: const CropAspectRatio(
            ratioX: 16, ratioY: 9), // Само ограничение
      );

      if (croppedFile != null) {
        setState(() {
          // Теперь используем croppedFile.path вместо оригинала
          _previewImagePath = croppedFile.path;
        });
      }
    }
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
              Text("Превью поста",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'SNPro',
                    fontWeight: FontWeight.w600
                ),),
              const SizedBox(height: 4),
              if (_previewImagePath == null) ElevatedButton.icon(
                onPressed: _pickAndCropImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Выберите изображение'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC9C9C9),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 6),

              if (_previewImagePath != null)
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_previewImagePath!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(right: 8, top:8, child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _pickAndCropImage();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8), // Внутренний отступ для иконки
                            decoration: BoxDecoration(
                              color: Colors.white, // Белый фон
                              shape: BoxShape.circle, // Круглая форма
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(15), // Легкая тень
                                  blurRadius: 4,
                                  offset: const Offset(0, 2), // Смещение тени вниз
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.edit, // Иконка карандаша
                              color: Color(0xFF424242), // Темно-серый цвет иконки
                              size: 20, // Размер иконки
                            ),
                          ),
                        ),
                        const SizedBox(width: 8), // Отступ между кнопками

                        // --- КНОПКА УДАЛИТЬ ---
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              // Обнуляем путь, чтобы скрыть фото
                              _previewImagePath = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.delete_outline, // Иконка корзины
                              color: Colors.redAccent, // Красный цвет для удаления
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ))
                  ],
                ),

              Text("Содержание",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'SNPro',
                    fontWeight: FontWeight.w600
                ),),
              const SizedBox(height: 4),
            ],
          ),
        ));
  }

}