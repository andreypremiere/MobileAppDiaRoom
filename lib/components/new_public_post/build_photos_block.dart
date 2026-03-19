import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/post_creator/block_photos.dart';

class PhotosBlockWidget extends StatelessWidget {
  final BlockPhotos block;
  final VoidCallback onChanged;

  const PhotosBlockWidget({
    super.key,
    required this.block,
    required this.onChanged,
  });

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        block.paths.addAll(pickedFiles.map((file) => file.path));
        onChanged(); // Сообщаем родителю, что список путей изменился
      }
    } catch (e) {
      print("Ошибка при выборе изображений: $e");
    }
  }

  Widget _buildDecoratedBox({required Widget child, Color? backgroundColor}) {
    const double borderRadius = 8;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: const Color(0xFFC9C9C9), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius - 1),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      height: 70 + 32, // blockHeight + padding
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              // Кнопка добавления фото
              GestureDetector(
                onTap: _pickImages,
                child: _buildDecoratedBox(
                  backgroundColor: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.add_a_photo_outlined,
                    color: Color(0xFF797979),
                    size: 24,
                  ),
                ),
              ),
              if (block.paths.isNotEmpty) const SizedBox(width: 8),

              // Список фото
              ...block.paths.asMap().entries.map((entry) {
                final int photoIndex = entry.key;
                final String path = entry.value;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildDecoratedBox(
                        child: Image.file(File(path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () {
                            block.paths.removeAt(photoIndex);
                            onChanged(); // Обновляем UI после удаления
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD3D3D3),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, size: 18, color: Color(0xFF2A2A2A)),
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
}