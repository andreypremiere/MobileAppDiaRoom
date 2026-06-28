import 'dart:io';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/configuration/constants.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import '../../models/post_creator/block_photos.dart';

class PhotosBlockWidget extends StatelessWidget {
  final BlockPhotosCreating block;
  final VoidCallback onChanged;

  const PhotosBlockWidget({
    super.key,
    required this.block,
    required this.onChanged,
  });

  Future<void> _pickImages(BuildContext context) async {
    try {
      if (block.isFull) {
        if (context.mounted) {
          await AppInfoDialog.show(
            context,
            "Лимит фотографий ($limitPhotosForBlockInPost) для блока уже достигнут.",
          );
        }
        return;
      }

      final ImagePicker picker = ImagePicker();
      List<XFile> pickedFiles = await picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        if (pickedFiles.length > limitPhotosForBlockInPost - block.listPhoto.length) {
          if (context.mounted) {
            AppInfoDialog.show(context, "В блок можно добавить не более $limitPhotosForBlockInPost фотографий.");
          }
          pickedFiles = pickedFiles.sublist(0, limitPhotosForBlockInPost - block.listPhoto.length);
        }

        for (final file in pickedFiles) {
          await block.addPath(file.path);
        }

        onChanged();
      }
    } catch (e) {
      if (context.mounted) {
        await AppInfoDialog.show(context, messageErrorCatch);
      }
    }
  }

  Widget _buildDecoratedBox(BuildContext context, {required Widget child}) {
    const double borderRadius = 8;
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: context.ui.containerColor,
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
      height: 70 + 32,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              if (!block.isFull)
                GestureDetector(
                  onTap: () => _pickImages(context),
                  child: _buildDecoratedBox(
                    context,
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      color: Color(0xFF797979),
                      size: 24,
                    ),
                  ),
                ),
              if (block.listPhoto.isNotEmpty) const SizedBox(width: 8),

              ...block.listPhoto.asMap().entries.map((entry) {
                final int photoIndex = entry.key;
                final String path = entry.value.filePath;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _buildDecoratedBox(context,
                        child: Image.file(File(path), fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: -6,
                        right: -6,
                        child: GestureDetector(
                          onTap: () async {
                            await block.deletePhoto(photoIndex);
                            onChanged();
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
}
