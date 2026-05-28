import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/api/account_api.dart';
import 'package:dia_room/api/diary_api.dart';
import 'package:dia_room/components/general/app_avatar.dart';
import 'package:dia_room/components/general/app_back_button.dart';
import 'package:dia_room/components/general/app_enum_picker.dart';
import 'package:dia_room/components/general/dialog_button.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:dia_room/components/room_screen/app_dialogs.dart';
import 'package:dia_room/contracts/room/requests/updating_avatar_request.dart';
import 'package:dia_room/contracts/room/requests/updating_background_request.dart';
import 'package:dia_room/contracts/room/requests/updating_text_field_request.dart';
import 'package:dia_room/contracts/room/responses/room_response.dart';
import 'package:dia_room/contracts/room/responses/updating_avatar_response.dart';
import 'package:dia_room/contracts/room/responses/updating_background_response.dart';
import 'package:dia_room/models/enums/file_type.dart';
import 'package:dia_room/models/enums/room/action_image_settings_screen.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/compress_image_service.dart';
import 'package:dia_room/utils/picker_image_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../components/info_dialog_component.dart';
import '../../components/loading_widget/error_widget.dart';
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
  RoomResponse? room;

  late String _roomId;
  late String _roomName;
  late String _bio;
  String? _backgroundPath;
  String? _avatarPath;

  // bool _compressMedia = true;

  bool _isLoading = true;
  String? _errorMessage;

  int _avatarVersion = 0;
  int _backgroundVersion = 0;

  // Новые переменные состояния
  final List<Categories> _selectedCategories = [];

  // double _fontSizeLevel = 2.0; // 1.0 - мелкий, 2.0 - средний, 3.0 - крупный

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await getRoomForSettings();

      if (!response.success) {
        _errorMessage =
            response.message ??
            "Непредвиденная ошибка при получении данных. Попробуйте обновить.";
        return;
      }

      room = RoomResponse.fromMap(response.data);

      _roomId = room!.roomUniqueId;
      _roomName = room!.roomName;
      _selectedCategories.clear();
      _selectedCategories.addAll(room!.listCategory);
      _bio = room!.bio;
      _backgroundPath = room!.backgroundPath;
      _avatarPath = room!.avatarPath;
    } catch (e) {
      _errorMessage =
          "Возникла ошибка в работе приложения. Пожалуйста, обратитесь в поддержку.";
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleUpdateAvatar() async {
    final ActionImageSettings? result = await showDialog<ActionImageSettings>(
      context: context,
      barrierDismissible: true, // Закрыть при нажатии на пустую область
      builder: (context) => const AppEnumPicker(values: ActionImageSettings.values),
    );

    if (result == null) {
      return;
    }

    switch (result) {
      case ActionImageSettings.edit:
        final path = await PickerImageService.pickAndCropAvatar();

        if (path == null || path.isEmpty) {
          return;
        }

        final compressedPath = await CompressImageService.compressForPreview(
          XFile(path),
        );
        if (compressedPath == null) {
          return;
        }

        final mimeType = DiaryUtils.getSupportedMimeType(compressedPath);
        if (mimeType == null) {
          return;
        }

        final UpdatingAvatarRequest request = UpdatingAvatarRequest(
          mimeType: mimeType,
        );

        final response = await updateAvatar(request);

        if (!response.success) {
          if (mounted) {
            await AppInfoDialog.show(context, "Не удалось обновить аватар комнаты. ${response.message ?? ""}");
          }
          return;
        }

        final UpdatingAvatarResponse data = UpdatingAvatarResponse.fromMap(
          response.data,
        );

        final resultUpload = await uploadSingleMediaFile(
          compressedPath,
          data.uploadUrl,
          mimeType,
        );
        if (resultUpload == false) {
          return;
        }

        await CachedNetworkImage.evictFromCache(data.publicUrl);

        if (mounted) {
          setState(() {
            _avatarPath = data.publicUrl;
            _avatarVersion++;
          });
        }
      case ActionImageSettings.delete:
        final response = await deleteAvatar();

        if (!response.success) {
          if (mounted) {
            await AppInfoDialog.show(context, response.message ?? "Не удалось удалить аватар комнаты");
          }
          return;
        }

        if (mounted) {
          setState(() {
            _avatarPath = "";
            _avatarVersion++;
          });
        }
    }
  }

  void _onRefresh() {
    _loadData();
  }

  Future<void> _handleUpdateBackground() async {
    final ActionImageSettings? result = await showDialog<ActionImageSettings>(
      context: context,
      barrierDismissible: true, // Закрыть при нажатии на пустую область
      builder: (context) => const AppEnumPicker(values: ActionImageSettings.values),
    );

    if (result == null) {
      return;
    }

    switch (result) {
      case ActionImageSettings.edit:
        final path = await PickerImageService.pickAndCropBackground();

        if (path == null || path.isEmpty) {
          return;
        }

        final compressedPath = await CompressImageService.compressForPreview(
          XFile(path),
        );
        if (compressedPath == null) {
          return;
        }

        final mimeType = DiaryUtils.getSupportedMimeType(compressedPath);
        if (mimeType == null) {
          return;
        }

        final UpdatingBackgroundRequest request = UpdatingBackgroundRequest(
          mimeType: mimeType,
        );

        final response = await updateBackground(request);

        if (!response.success) {
          if (mounted) {
            await AppInfoDialog.show(context, "Не удалось обновить фон комнаты. ${response.message ?? ""}");
          }
          return;
        }

        final UpdatingBackgroundResponse data = UpdatingBackgroundResponse.fromMap(
          response.data,
        );

        final resultUpload = await uploadSingleMediaFile(
          compressedPath,
          data.uploadUrl,
          mimeType,
        );
        if (resultUpload == false) {
          return;
        }

        await CachedNetworkImage.evictFromCache(data.publicUrl);

        if (mounted) {
          setState(() {
            _backgroundPath = data.publicUrl;
            _backgroundVersion++;
          });
        }
      case ActionImageSettings.delete:
        final response = await deleteBackground();

        if (!response.success) {
          if (mounted) {
            await AppInfoDialog.show(context, response.message ?? "Не удалось удалить фон комнаты");
          }
          return;
        }

        if (mounted) {
          setState(() {
            _backgroundPath = "";
            _backgroundVersion++;
          });
        }
    }


  }

  Future<void> _handleUpdateUniqueId(String newValue) async {
    final resultCheck = isValidRoomId(newValue);
    if (resultCheck != null) {
      return;
    }

    final response = await updateRoomUniqueId(
      UpdatingTextFieldRequest(value: newValue),
    );

    if (!response.success) {
      return;
    }

    if (mounted) {
      setState(() {
        _roomId = newValue;
      });
    }
  }

  Future<void> _handleUpdateRoomName(String newValue) async {
    final resultCheck = isValidRoomName(newValue);
    if (!resultCheck) {
      return;
    }

    final response = await updateRoomName(
      UpdatingTextFieldRequest(value: newValue),
    );

    if (!response.success) {
      return;
    }

    if (mounted) {
      setState(() {
        _roomName = newValue;
      });
    }
  }

  Future<void> _handleUpdateBio(String newValue) async {
    final response = await updateRoomBio(
      UpdatingTextFieldRequest(value: newValue),
    );

    if (!response.success) {
      return;
    }

    if (mounted) {
      setState(() {
        _bio = newValue;
      });
    }
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
      // Показать ошибку?
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
          await AppInfoDialog.show(
            context,
            result.message ?? "Не удалось выйти из приложения",
          );
        }
      }
    }
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Категории комнаты",
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
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
                        "Выбрано: ${tempSelectedCategories.length}/3",
                        // Используем временный список
                        style: const TextStyle(
                          fontFamily: 'SNPro',
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: categoriesToDisplay.length,
                        itemBuilder: (context, index) {
                          final category = categoriesToDisplay[index];
                          // Проверяем временный список
                          final isSelected = tempSelectedCategories.contains(
                            category,
                          );

                          return CheckboxListTile(
                            title: Text(
                              category.label,
                              style: const TextStyle(
                                fontFamily: 'SNPro',
                                fontSize: 16,
                              ),
                            ),
                            value: isSelected,
                            activeColor: const Color(0xFF525252),
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            // Отключаем чекбоксы, пока идет отправка данных
                            enabled: !isLoading,
                            onChanged: (bool? checked) {
                              if (mounted) {
                                setStateDialog(() {
                                  if (checked == true) {
                                    if (tempSelectedCategories.length < 3) {
                                      tempSelectedCategories.add(category);
                                    }
                                  } else {
                                    tempSelectedCategories.remove(category);
                                  }
                                });
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Row(
                  children: [
                    DialogButton(
                      text: "Отмена",
                      onPressed: () {
                        if (isLoading) return;

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      textColor: context.ui.fontColorHint,
                      isTransparent: true,
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 10,
                      ),
                    ),
                    const Spacer(),
                    _isLoading
                        ? DiaRoomLoader()
                        : DialogButton(
                            text: "Сохранить",
                            onPressed: () async {
                              if (isLoading) {
                                return;
                              }

                              if (mounted) {
                                setStateDialog(() => isLoading = true);
                              }

                              // 2. Отправляем запрос
                              final success = await _handleUpdateCategories(
                                tempSelectedCategories,
                              );

                              // 3. Скрываем лоадер
                              if (mounted) {
                                setStateDialog(() => isLoading = false);
                              }

                              // 4. Если всё хорошо — обновляем ГЛАВНЫЙ стейт экрана и закрываем диалог
                              if (success) {
                                if (mounted) {
                                  setState(() {
                                    _selectedCategories.clear();
                                    _selectedCategories.addAll(
                                      tempSelectedCategories,
                                    );
                                  });
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 10,
                            ),
                          ),
                  ],
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
    if (_errorMessage != null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          elevation: 0,
          leading: const AppBackButton(),
          centerTitle: false,
          title: const Text("Ошибка"),
        ),
        body: Center(
          child: DiaRoomErrorView(
            errorMessage: _errorMessage!,
            onRefresh: _onRefresh,
          ),
        ),
      );
    }

    // ПЕРВОНАЧАЛЬНАЯ ЗАГРУЗКА: Пока данных нет, крутим фирменный лоадер
    if (_isLoading && room == null) {
      return const Scaffold(body: Center(child: DiaRoomLoader()));
    }

    // 3. ПРЕДОХРАНИТЕЛЬ: Если загрузка завершилась, но данных почему-то нет
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          elevation: 0,
          leading: const AppBackButton(),
        ),
        body: const Center(
          child: Text(
            "Данные комнаты отсутствуют",
            style: TextStyle(fontFamily: 'SNPro', fontSize: 16),
          ),
        ),
      );
    }

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
      body: SingleChildScrollView(
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
                AppDialogs.showEditDialog(
                  context,
                  title: "Изменить ID",
                  currentValue: _roomId,
                  onSave: _handleUpdateUniqueId,
                );
              },
            ),
            _buildListTile(
              title: "Название",
              subtitle: _roomName,
              onTap: () {
                AppDialogs.showEditDialog(
                  context,
                  title: "Изменить название",
                  currentValue: _roomName,
                  onSave: _handleUpdateRoomName,
                );
              },
            ),
            _buildListTile(
              title: "Описание",
              subtitle: _bio,
              onTap: () {
                AppDialogs.showEditDialog(
                  context,
                  title: "Изменить описание",
                  currentValue: _bio,
                  onSave: _handleUpdateBio,
                  stroke: 4,
                );
              },
            ),
            _buildListTile(
              title: "Категории",
              subtitle: _getCategoriesSubtitle(),
              onTap: _showCategoriesDialog,
            ),
            const SizedBox(height: 24),

            // Секция Аккаунт
            _buildSectionHeader("Аккаунт"),
            _buildActionTile(
              title: "Выйти из аккаунта",
              icon: Icons.logout,
              color: Colors.redAccent,
              onTap: () async {
                final bool? result = await AppDialogs.showConfirmDialog(context, text: "Вы уверены, что хотите выйти?", cancelText: "Отмена", confirmText: "Выйти");

                if (result != null && result) {
                  if (context.mounted) {
                    await _handleLogout(context);
                  }
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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

    return GestureDetector(onTap: _backgroundPath != null && _backgroundPath!.isNotEmpty ? () {
      context.push(
        '/full_image_screen',
        extra: {
          'urls': [_backgroundPath.toString()],
          'index': 0,
          'type': FileType.network,
        },
      );
    } : () {},
    child: SizedBox(
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
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CupertinoActivityIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF0F0F0),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(Icons.error, color: Colors.grey),
          ),
        ),
      )
          : Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.wallpaper, color: Colors.grey, size: 40),
        ),
      ),
    ),);
  }

  Widget _buildAvatarContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: AppAvatar(avatarPath: _avatarPath, radius: 50,),);
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
        child: const Icon(Icons.more_vert_rounded, size: 16, color: Color(0xFF525252)),
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

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'SNPro',
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                subtitle,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 16,
                  color: Colors.grey,
                ),
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

  // Widget _buildSwitchTile({
  //   required String title,
  //   required bool value,
  //   required ValueChanged<bool> onChanged,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontFamily: 'SNPro',
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         CupertinoSwitch(
  //           value: value,
  //           activeColor: context.ui.primaryColor,
  //           onChanged: onChanged,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Кастомный элемент списка с трехпозиционным ползунком
  // Widget _buildDiscreteSliderTile({
  //   required String title,
  //   required double value,
  //   required ValueChanged<double> onChanged,
  // }) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text(
  //           title,
  //           style: const TextStyle(
  //             fontFamily: 'SNPro',
  //             fontSize: 16,
  //             fontWeight: FontWeight.w500,
  //           ),
  //         ),
  //         const SizedBox(height: 4),
  //         Row(
  //           children: [
  //             const Text(
  //               "1",
  //               style: TextStyle(
  //                 fontFamily: 'SNPro',
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //               ),
  //             ),
  //             Expanded(
  //               child: SliderTheme(
  //                 data: SliderTheme.of(context).copyWith(
  //                   activeTrackColor: const Color(0xFF525252),
  //                   inactiveTrackColor: const Color(0xFFE8E8E8),
  //                   trackHeight: 3.0,
  //                   thumbColor: const Color(0xFF525252),
  //                   thumbShape: const RoundSliderThumbShape(
  //                     enabledThumbRadius: 8.0,
  //                   ),
  //                   overlayColor: const Color(0xFF525252).withAlpha(30),
  //                   tickMarkShape: const RoundSliderTickMarkShape(
  //                     tickMarkRadius: 2.0,
  //                   ),
  //                   activeTickMarkColor: const Color(0xFF525252),
  //                   inactiveTickMarkColor: const Color(0xFFB4B4B4),
  //                 ),
  //                 child: Slider(
  //                   value: value,
  //                   min: 1.0,
  //                   max: 3.0,
  //                   divisions: 2,
  //                   // Разделяет слайдер ровно на 3 точки: 1.0, 2.0 и 3.0
  //                   onChanged: onChanged,
  //                 ),
  //               ),
  //             ),
  //             const Text(
  //               "3",
  //               style: TextStyle(
  //                 fontFamily: 'SNPro',
  //                 color: Colors.grey,
  //                 fontSize: 12,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
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
