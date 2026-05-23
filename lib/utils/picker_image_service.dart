import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class PickerImageService {
  static Future<String?> pickAndCropAvatar() async {
    final picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            cropStyle: CropStyle.circle,
            toolbarTitle: 'Обрежьте аватар',
            toolbarColor: const Color(0xFFB4B4B4),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF525252),
            backgroundColor: const Color(0xFFF5F5F5),
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Обрежьте аватар',
            aspectRatioLockEnabled: true, // Запрещает менять соотношение сторон
            rotateButtonsHidden: false,   // Оставляем кнопку поворота
            resetAspectRatioEnabled: true, // Кнопка сброса
            rectWidth: 300,
            rectHeight: 300,
          ),
        ],
      );

      if (croppedFile != null) {
        return croppedFile.path;
      }
    }

    return null;
  }

  static Future<String?> pickAndCropBackground() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            cropStyle: CropStyle.rectangle,
            toolbarTitle: 'Обрежьте фон',
            toolbarColor: const Color(0xFFB4B4B4),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF525252),
            backgroundColor: const Color(0xFFF5F5F5),
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Обрежьте фон 16:9',
            aspectRatioLockEnabled: true,
          ),
        ],
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      );

      if (croppedFile != null) {
        return croppedFile.path;
      }
    }
    return null;
  }

  static Future<void> deletePhysicalFile(String? path) async {
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      return;
    }
  }
}
