import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/api/diary_api.dart';
import 'package:dia_room/components/general/app_back_button.dart';
import 'package:dia_room/contracts/room/requests/updating_avatar_request.dart';
import 'package:dia_room/contracts/room/requests/updating_background_request.dart';
import 'package:dia_room/contracts/room/requests/updating_text_field_request.dart';
import 'package:dia_room/contracts/room/responses/room_response.dart';
import 'package:dia_room/contracts/room/responses/updating_avatar_response.dart';
import 'package:dia_room/contracts/room/responses/updating_background_response.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../components/info_dialog_component.dart';
import '../../contracts/room/requests/updating_categories_request.dart';
import '../../models/enums/categories.dart';
import '../../utils/auth_service.dart';
import '../../utils/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ImagePicker _picker = ImagePicker();

  late RoomResponse room;

  late String _roomId;
  late String _roomName;
  late String _bio;
  String? _backgroundPath;
  String? _avatarPath;

  bool _compressMedia = true;

  bool _isLoading = true;
  bool _isError = false;

  int _avatarVersion = 0;
  int _backgroundVersion = 0;

  // Новые переменные состояния
  final List<Categories> _selectedCategories = [];
  double _fontSizeLevel = 2.0; // 1.0 - мелкий, 2.0 - средний, 3.0 - крупный

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      final response = await getRoomForSettings();

      if (!response.success) {
        print('Не удалось получить данные комнаты');
        _isError = true;
        return;
      }

      room = RoomResponse.fromMap(response.data);

      _roomId = room.roomUniqueId;
      _roomName = room.roomName;
      _selectedCategories.clear();
      _selectedCategories.addAll(room.listCategory);
      _bio = room.bio;
      _backgroundPath = room.backgroundPath;
      _avatarPath = room.avatarPath;

      print("Полученные данные ${room.toMap()}");

    } catch (e) {
      print("Возникла ошибка при подргрузке данных : $e");
      _isError = true;
      return;
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleUpdateAvatar() async {
    final path = await _pickAndCropAvatar();

    if (path == null || path.isEmpty) {
      print("Путь равен нулю");
      return;
    }

    print("Сжатие");
    final compressedPath = await CompressImageService.compressForPreview(XFile(path));
    if (compressedPath == null) {
      print("Не удалось сжать изображение");
      return;
    }

    final mimeType = DiaryUtils.getSupportedMimeType(compressedPath);
    if (mimeType == null) {
      print('Не удалось получить mimeType');
      return;
    }
    print("Полученный mimeType: $mimeType");

    print("Обновление");
    final UpdatingAvatarRequest request = UpdatingAvatarRequest(mimeType: mimeType);

    final response = await updateAvatar(request);

    if (!response.success) {
      print("Ошибка при обновлении на сервере");
    }

    final UpdatingAvatarResponse data = UpdatingAvatarResponse.fromMap(response.data);

    print("Загрузка");
    final resultUpload = await uploadSingleMediaFile(compressedPath, data.uploadUrl, mimeType);
    if (resultUpload == false) {
      print("Не удалось загрузить фотографию в хранилище");
      return;
    }

    await CachedNetworkImage.evictFromCache(data.publicUrl);

    setState(() {
      _avatarPath = data.publicUrl;
      _avatarVersion++;
    });
  }

  Future<void> _handleUpdateBackground() async {
    final path = await _pickAndCropBackground();

    if (path == null || path.isEmpty) {
      print("Путь равен нулю");
      return;
    }

    print("Сжатие");
    final compressedPath = await CompressImageService.compressForPreview(XFile(path));
    if (compressedPath == null) {
      print("Не удалось сжать изображение");
      return;
    }

    final mimeType = DiaryUtils.getSupportedMimeType(compressedPath);
    if (mimeType == null) {
      print('Не удалось получить mimeType');
      return;
    }
    print("Полученный mimeType: $mimeType");

    print("Обновление");
    final UpdatingBackgroundRequest request = UpdatingBackgroundRequest(mimeType: mimeType);

    final response = await updateBackground(request);

    if (!response.success) {
      print("Ошибка при обновлении на сервере");
    }

    final UpdatingBackgroundResponse data = UpdatingBackgroundResponse.fromMap(response.data);

    print("Загрузка");
    final resultUpload = await uploadSingleMediaFile(compressedPath, data.uploadUrl, mimeType);
    if (resultUpload == false) {
      print("Не удалось загрузить фотографию в хранилище");
      return;
    }

    await CachedNetworkImage.evictFromCache(data.publicUrl);

    setState(() {
      _backgroundPath = data.publicUrl;
      _backgroundVersion++;
    });
  }

  Future<void> _handleUpdateUniqueId(String newValue) async {
    final resultCheck = isValidRoomId(newValue);
    if (resultCheck != null) {
      print("Проверка не пройдена");
      return;
    }

    final response = await updateRoomUniqueId(UpdatingTextFieldRequest(value: newValue));

    if (!response.success) {
      print("Не удалось обновить");
      return;
    }

    setState(() {
      _roomId = newValue;
    });
  }

  Future<void> _handleUpdateRoomName(String newValue) async {
    final resultCheck = isValidRoomName(newValue);
    if (!resultCheck) {
      print("Проверка не пройдена");
      return;
    }

    final response = await updateRoomName(UpdatingTextFieldRequest(value: newValue));

    if (!response.success) {
      print("Не удалось обновить");
      return;
    }

    setState(() {
      _roomName = newValue;
    });
  }

  Future<void> _handleUpdateBio(String newValue) async {
    final response = await updateRoomBio(UpdatingTextFieldRequest(value: newValue));

    if (!response.success) {
      print("Не удалось обновить");
      return;
    }

    setState(() {
      _bio = newValue;
    });
  }

  Future<bool> _handleUpdateCategories(List<Categories> newCategories) async {
    // 1. Формируем запрос
    final request = UpdatingCategoriesRequest(categories: newCategories);

    // 2. Отправляем запрос на сервер
    final response = await updateCategories(request);

    // 3. Обрабатываем результат
    if (response.success) {
      return true; // Успех
    } else {
      // // Показываем ошибку пользователю (если handleDioError возвращает errorMessage)
      // // Либо просто дефолтный текст
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text("Ошибка: не удалось обновить категории"),
      //       backgroundColor: Colors.redAccent,
      //     ),
      //   );
      // }
      return false; // Ошибка
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    // Выполнить запрос выхода
    final result = await requestLogout(context);
    if (result == null) {
      if (context.mounted) {
        await context.read<AuthProvider>().logout();
      }
    } else {
      if (result.success) {
        if (context.mounted) {
          await context.read<AuthProvider>().logout();
        }
      } else {
        if (context.mounted) {
          await AppInfoDialog.show(context, result.message ?? "Не удалось выйти из приложения");
        }
      }
    }
  }

  // --- ОБРАБОТКА ИЗОБРАЖЕНИЙ ---

  Future<String?> _pickAndCropAvatar() async {
    final XFile? pickedFile = await _picker.pickImage(
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
          ),
          IOSUiSettings(title: 'Обрежьте аватар', aspectRatioLockEnabled: true),
        ],
      );

      if (croppedFile != null) {
        return croppedFile.path;
      }
    }

    return null;
  }

  Future<String?> _pickAndCropBackground() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
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
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      );

      if (croppedFile != null) {
        return croppedFile.path;
      }
    }
    return null;
  }

  // --- МОДАЛЬНОЕ ОКНО ДЛЯ РЕДАКТИРОВАНИЯ ТЕКСТА ---

  void _showEditDialog(String title, String currentValue, Function(String) onSave, {int? stroke = 1}) {
    final TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFF8F8F8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            title,
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 20, fontWeight: FontWeight.w600),
          ),
          content: TextField(
            minLines: 1,
            maxLines: stroke,
            controller: controller,
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
            decoration: InputDecoration(

              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFB4B4B4), width: 1.5),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Отмена",
                style: TextStyle(color: Colors.grey, fontFamily: 'SNPro', fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () async {
                await onSave(controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text(
                "Сохранить",
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
  }

  // --- МОДАЛЬНОЕ ОКНО ВЫБОРА КАТЕГОРИЙ ---

  void _showCategoriesDialog() {
    // Создаем ВРЕМЕННУЮ копию текущих выбранных категорий
    List<Categories> tempSelectedCategories = List.from(_selectedCategories);

    // Флаг для отображения индикатора загрузки
    bool isLoading = false;

    showDialog(
      context: context,
      // Запрещаем закрывать окно случайным тапом мимо, пока идет загрузка
      barrierDismissible: !isLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final categoriesToDisplay = Categories.values
                .where((c) => c != Categories.defaultVal)
                .toList();

            return AlertDialog(
              backgroundColor: const Color(0xFFF8F8F8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text(
                "Категории комнаты",
                style: TextStyle(fontFamily: 'SNPro', fontSize: 20, fontWeight: FontWeight.w600),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
                      child: Text(
                        "Выбрано: ${tempSelectedCategories.length}/3", // Используем временный список
                        style: const TextStyle(fontFamily: 'SNPro', fontSize: 14, color: Colors.grey),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categoriesToDisplay.length,
                        itemBuilder: (context, index) {
                          final category = categoriesToDisplay[index];
                          // Проверяем временный список
                          final isSelected = tempSelectedCategories.contains(category);

                          return CheckboxListTile(
                            title: Text(
                              category.label,
                              style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
                            ),
                            value: isSelected,
                            activeColor: const Color(0xFF525252),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            // Отключаем чекбоксы, пока идет отправка данных
                            enabled: !isLoading,
                            onChanged: (bool? checked) {
                              setStateDialog(() {
                                if (checked == true) {
                                  if (tempSelectedCategories.length < 3) {
                                    tempSelectedCategories.add(category);
                                  }
                                } else {
                                  tempSelectedCategories.remove(category);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Кнопка отмены (чтобы можно было выйти без сохранения)
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    "Отмена",
                    style: TextStyle(color: Colors.grey, fontFamily: 'SNPro', fontSize: 16),
                  ),
                ),
                // Кнопка сохранения
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    // 1. Показываем лоадер
                    setStateDialog(() => isLoading = true);

                    // 2. Отправляем запрос
                    final success = await _handleUpdateCategories(tempSelectedCategories);

                    // 3. Скрываем лоадер
                    setStateDialog(() => isLoading = false);

                    // 4. Если всё хорошо — обновляем ГЛАВНЫЙ стейт экрана и закрываем диалог
                    if (success) {
                      setState(() {
                        _selectedCategories.clear();
                        _selectedCategories.addAll(tempSelectedCategories);
                      });

                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF525252)
                    ),
                  )
                      : const Text(
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

  // --- Вспомогательный метод получения текста для подзаголовка категорий ---
  String _getCategoriesSubtitle() {
    if (_selectedCategories.isEmpty) {
      return "Не выбраны";
    }
    return _selectedCategories.map((e) => e.label).join(", ");
  }

  // --- ОСНОВНОЙ BUILD ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: const AppBackButton(),
        centerTitle: false,
        title: const Text(
          'Настройки',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 22,
            fontFamily: 'SNPro',
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _buildBody()
    );
  }


  Widget _buildBody() {
    if (_isLoading && !_isError) {
      return Center(child: CircularProgressIndicator());
    } else if (!_isLoading && _isError) {
      return Center(child: Text("Не удалось загрузить данные"),);
    } else if (!_isLoading && !_isError) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),

            // Секция Профиль
            _buildSectionHeader("Профиль"),
            _buildListTile(
              title: "ID комнаты",
              subtitle: _roomId,
              onTap: () {
                _showEditDialog("Изменить ID", _roomId, _handleUpdateUniqueId);
              },
            ),
            _buildListTile(
              title: "Название",
              subtitle: _roomName,
              onTap: () {
                _showEditDialog("Изменить название", _roomName, _handleUpdateRoomName);
              },
            ),
            _buildListTile(
              title: "Описание",
              subtitle: _bio,
              onTap: () {
                _showEditDialog("Изменить описание", _bio, _handleUpdateBio, stroke: 4);
              },
            ),
            _buildListTile(
              title: "Категории",
              subtitle: _getCategoriesSubtitle(),
              onTap: _showCategoriesDialog,
            ),
            // const SizedBox(height: 24),
            //
            // // Секция Интерфейс (Новый раздел с трехпозиционным ползунком)
            // _buildSectionHeader("Интерфейс"),
            // _buildDiscreteSliderTile(
            //   title: "Крупность шрифта",
            //   value: _fontSizeLevel,
            //   onChanged: (double newValue) {
            //     setState(() {
            //       _fontSizeLevel = newValue;
            //     });
            //   },
            // ),
            // const SizedBox(height: 24),
            //
            // // Секция Оптимизация
            // _buildSectionHeader("Оптимизация"),
            // _buildSwitchTile(
            //   title: "Сжимать медиа",
            //   value: _compressMedia,
            //   onChanged: (val) {
            //     setState(() => _compressMedia = val);
            //   },
            // ),
            const SizedBox(height: 24),

            // Секция Аккаунт
            _buildSectionHeader("Аккаунт"),
            _buildActionTile(
              title: "Выйти из аккаунта",
              icon: Icons.logout,
              color: Colors.redAccent,
              onTap: () async {
                await _handleLogout(context);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    }
    return SizedBox.shrink();
  }

  // --- UI КОМПОНЕНТЫ ---

  // Шапка: Фон + Аватар
  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const SizedBox(height: 230, width: double.infinity),
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: _buildBackgroundContainer(),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: _buildEditButton(onTap: _handleUpdateBackground),
        ),
        Positioned(
          bottom: 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildAvatarContainer(),
              Positioned(
                bottom: 0,
                right: -4,
                child: _buildEditButton(onTap: _handleUpdateAvatar),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundContainer() {
    // Проверяем, есть ли ссылка
    bool hasImage = _backgroundPath != null && _backgroundPath!.isNotEmpty;

    return SizedBox(
      height: 160,
      width: double.infinity,
      child: hasImage
          ? CachedNetworkImage(
        key: ValueKey('$_backgroundPath-$_backgroundVersion'),
        imageUrl: _backgroundPath!,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(16)),
          child: const Center(child: CupertinoActivityIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(color: const Color(0xFFF0F0F0), borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Icon(Icons.error, color: Colors.grey)),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: Icon(Icons.wallpaper, color: Colors.grey, size: 40)),
      ),
    );
  }

  Widget _buildAvatarContainer() {
    bool hasImage = _avatarPath != null && _avatarPath!.isNotEmpty;

    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: hasImage
          ? ClipOval(
        child: CachedNetworkImage(
          key:ValueKey('$_avatarPath-$_avatarVersion'),
          imageUrl: _avatarPath!,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.error, color: Colors.grey),
        ),
      )
          : const Center(child: Icon(Icons.person, color: Colors.grey, size: 40)),
    );
  }

  Widget _buildEditButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
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
        child: const Icon(Icons.edit, size: 16, color: Color(0xFF525252)),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'SNPro',
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontFamily: 'SNPro', fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subtitle,
                textAlign: TextAlign.right,
                style: const TextStyle(fontFamily: 'SNPro', fontSize: 16, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 16, fontWeight: FontWeight.w500),
          ),
          CupertinoSwitch(
            value: value,
            activeColor: context.ui.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // Кастомный элемент списка с трехпозиционным ползунком
  Widget _buildDiscreteSliderTile({
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text("1", style: TextStyle(fontFamily: 'SNPro', color: Colors.grey, fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF525252),
                    inactiveTrackColor: const Color(0xFFE8E8E8),
                    trackHeight: 3.0,
                    thumbColor: const Color(0xFF525252),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
                    overlayColor: const Color(0xFF525252).withAlpha(30),
                    tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 2.0),
                    activeTickMarkColor: const Color(0xFF525252),
                    inactiveTickMarkColor: const Color(0xFFB4B4B4),
                  ),
                  child: Slider(
                    value: value,
                    min: 1.0,
                    max: 3.0,
                    divisions: 2, // Разделяет слайдер ровно на 3 точки: 1.0, 2.0 и 3.0
                    onChanged: onChanged,
                  ),
                ),
              ),
              const Text("3", style: TextStyle(fontFamily: 'SNPro', color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'SNPro',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}