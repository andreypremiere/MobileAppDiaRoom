import 'dart:io';
import 'package:dia_room/contracts/room/requests/save_room_request.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/account_api.dart';
import '../../components/info_dialog_component.dart';
import '../../models/enums/categories.dart';
import '../../utils/utils.dart';


class RoomSettingsScreen extends StatefulWidget {
  const RoomSettingsScreen({super.key});

  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _avatarPath;
  String? _backgroundPath;
  final List<Categories> _selectedCategories = [];

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  // --- ОБРАБОТКА ИЗОБРАЖЕНИЙ ---

  Future<void> _deletePhysicalFile(String? path) async {
    if (path == null || path.isEmpty) return;

    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        print("Файл удален: $path");
      }
    } catch (e) {
      print("Ошибка при удалении файла: $e");
    }
  }

  Future<void> _pickAndCropAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // cropStyle: CropStyle.circle, // Круглый шаблон для аватара
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
          ),
          IOSUiSettings(title: 'Обрежьте аватар', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        setState(() => _avatarPath = croppedFile.path);
      }
    }
  }

  Future<void> _pickAndCropBackground() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        // cropStyle: CropStyle.rectangle,
        uiSettings: [
          AndroidUiSettings(
            cropStyle: CropStyle.rectangle,
            toolbarTitle: 'Обрежьте фон 16:9',
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
        aspectRatio: const CropAspectRatio(
          ratioX: 16,
          ratioY: 9,
        ), // 16:9 для фона
      );

      if (croppedFile != null) {
        setState(() => _backgroundPath = croppedFile.path);
      }
    }
  }

  // --- ОБРАБОТКА КАТЕГОРИЙ ---

  void _showCategoryPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: const Color(0xFFF8F8F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Выберите категории (до 3)",
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Categories.values.length,
                  itemBuilder: (context, index) {
                    final category = Categories.values[index];
                    final isSelected = _selectedCategories.contains(category);

                    return CheckboxListTile(
                      title: Text(
                        category.label,
                        style: const TextStyle(fontFamily: 'SNPro'),
                      ),
                      value: isSelected,
                      activeColor: const Color(0xFF525252),
                      onChanged: (bool? value) {
                        if (value == true) {
                          if (_selectedCategories.length < 3) {
                            setState(() => _selectedCategories.add(category));
                            setStateDialog(() {});
                          } else {
                            AppInfoDialog.show(
                              context,
                              "Можно выбрать только 3 категории :(",
                            );
                          }
                        } else {
                          setState(() => _selectedCategories.remove(category));
                          setStateDialog(() {});
                        }
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Готово",
                    style: TextStyle(
                      color: Color(0xFF525252),
                      fontFamily: 'SNPro',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _removeCategory(String category) {
    setState(() {
      _selectedCategories.remove(category);
    });
  }

  void _handleSaveRoom() async {
    final roomId = _idController.text.trim();
    final resultCheck = isValidRoomId(roomId);
    if (resultCheck != null) {
      AppInfoDialog.show(context, resultCheck);
      return;
    }

    final roomName = _nameController.text.trim();
    if (roomName.isEmpty) {
      AppInfoDialog.show(
        context,
        "Наименование не должно быть пустым: (",
      );
      return;
    }

    if (!isValidRoomName(roomName)) {
      AppInfoDialog.show(
        context,
        "Наименование должно быть короче 100 символов : (",
      );
      return;
    }

    SaveRoomRequest room = SaveRoomRequest(
      roomUniqueId: roomId,
      roomName: roomName,
      listCategory: _selectedCategories,
      bio: _bioController.text.trim(),
      avatarPath: _avatarPath,
      backgroundPath: _backgroundPath,
    );


    print('room перед отправкой: $room');
    final response = await requestUpdateRoom(context, room);

    if (!response.success) {
      // 2. Ждем закрытия диалога
      await AppInfoDialog.show(context, response.message.toString());
      return;
    }

    context.read<AuthProvider>().saveStatusConfigure(true);

    () async {
      if (_avatarPath != null &&
          _avatarPath!.isNotEmpty &&
          response.data!.containsKey('presignedUrlAvatar') &&
          response.data!['presignedUrlAvatar'].isNotEmpty) {
        File fileAvatar = File(_avatarPath!);
        if (!await fileAvatar.exists()) {
          print('Файл _avatarPath не существует');
        } else {
          await requestUploadImage(response.data!['presignedUrlAvatar'], fileAvatar);
        }
      }

      if (_backgroundPath != null &&
          _backgroundPath!.isNotEmpty &&
          response.data!.containsKey('presignedUrlBackground') &&
          response.data!['presignedUrlBackground'].isNotEmpty) {

        File fileBackground = File(_backgroundPath!);

        if (!await fileBackground.exists()) {
          print('Файл _backgroundPath не существует по пути: $_backgroundPath');
        } else {
          await requestUploadImage(response.data!['presignedUrlBackground'], fileBackground);
        }
      }
      print('Все изображения успешно загружены');
    }();

    context.go('/');

  }

  // --- ОСНОВНОЙ BUILD ---

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: _buildAppBar(),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle("ID комнаты", isRequired: true),
                  _buildCustomField(
                    controller: _idController,
                    hint: 'Например: my_awesome_room',
                  ),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Название комнаты", isRequired: true),
                  _buildCustomField(controller: _nameController, hint: 'Например: My room'),
                  const SizedBox(height: 20),

                  _buildSectionTitle("Аватар"),
                  const SizedBox(height: 8),
                  _buildAvatarPicker(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Фон комнаты"),
                  const SizedBox(height: 8),
                  _buildBackgroundPicker(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Ваше творчество"),
                  const SizedBox(height: 8),
                  _buildCategorySelector(),
                  const SizedBox(height: 24),

                  _buildSectionTitle("Описание"),
                  _buildCustomField(
                    controller: _bioController,
                    hint: 'Расскажите о вашей комнате...',
                    minLines: 2,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  // --- UI КОМПОНЕНТЫ ---

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: context.ui.appBarColor,
      elevation: 0,
      title: const Text(
        'Настройка комнаты',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSectionTitle(String text, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 18,
            fontFamily: 'SNPro',
            fontWeight: FontWeight.w600,
            color: Colors.black, // Добавь цвет, иначе в RichText он может быть белым по умолчанию
          ),
          children: [
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomField({
    required TextEditingController controller,
    String? hint,
    int minLines = 1,
    int? maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB4B4B4), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildAvatarPicker() {
    if (_avatarPath == null) {
      return Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: _pickAndCropAvatar,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD1D1D1)),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              size: 36,
              color: Colors.grey,
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.center,
      child: Stack(
        children: [
          ClipOval(
            child: Image.file(
              File(_avatarPath!),
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Row(
              children: [
                // _buildCircleBtn(Icons.edit, _pickAndCropAvatar),
                _buildCircleBtn(Icons.delete_outline, () async {
                  await _deletePhysicalFile(_avatarPath);

                  setState(() {
                    _avatarPath = null;
                  });
                }, isRed: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPicker() {
    if (_backgroundPath == null) {
      return InkWell(
        onTap: _pickAndCropBackground,
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD1D1D1)),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 40,
                color: Colors.grey,
              ),
              SizedBox(height: 8),
              Text(
                "Нажмите, чтобы добавить фон",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(_backgroundPath!), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Row(
            children: [
              // _buildCircleBtn(Icons.edit, _pickAndCropBackground),
              // const SizedBox(width: 8),
              _buildCircleBtn(Icons.delete_outline, () async {
                await _deletePhysicalFile(_backgroundPath);

                setState(() {
                  _backgroundPath = null;
                });
              }, isRed: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCircleBtn(
    IconData icon,
    VoidCallback onTap, {
    bool isRed = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4),
          ],
        ),
        child: Icon(
          icon,
          color: isRed ? Colors.red : const Color(0xFF424242),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showCategoryPopup,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D1D1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCategories.isEmpty
                      ? "Выберите категории..."
                      : "Выбрано: ${_selectedCategories.length}/3",
                  style: TextStyle(
                    fontFamily: 'SNPro',
                    fontSize: 16,
                    color: _selectedCategories.isEmpty
                        ? Colors.black26
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
              ],
            ),
          ),
        ),
        if (_selectedCategories.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _selectedCategories
                .map((category) => _buildTagChip(category.label))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagChip(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1D1D1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(tag, style: const TextStyle(fontFamily: 'SNPro', fontSize: 14)),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeCategory(tag),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF797979)),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: const Color(0xFFF8F8F8), border: null),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  await AppInfoDialog.show(
                    context,
                    "Вы можете изменить параметры в настройках :)",
                  );
                  print("Выполнилось действие пропустить");

                  requestSetConfigured();

                  context.read<AuthProvider>().saveStatusConfigure(true);
                  context.go('/');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: context.ui.primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  "Пропустить",
                  style: TextStyle(
                    color: context.ui.fontColorPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  _handleSaveRoom();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: context.ui.primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "Сохранить",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
