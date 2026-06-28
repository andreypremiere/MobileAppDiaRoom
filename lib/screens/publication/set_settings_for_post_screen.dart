import 'dart:io';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/services/public_post_creating/creating_post_service.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../components/diary/link_button.dart';
import '../../components/general/app_back_button.dart';
import '../../components/info_dialog_component.dart';
import '../../models/enums/categories.dart';
import '../../utils/auth_service.dart';


class SetSettingsForPostScreen extends StatefulWidget {
  final PostDraft postDraft;

  const SetSettingsForPostScreen({super.key, required this.postDraft});

  @override
  State<SetSettingsForPostScreen> createState() => _SetSettingsForPostState();
}

class _SetSettingsForPostState extends State<SetSettingsForPostScreen> {
  final TextEditingController _namePostController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _namePostController.text = widget.postDraft.name;


    _namePostController.addListener(() {
      widget.postDraft.name = _namePostController.text;
    });
  }

  @override
  void dispose() {
    _namePostController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _handleTagInput(String value) {
    if (value.endsWith(' ') || value.endsWith(',')) {
      String tag = value.replaceAll(',', '').trim();

      if (tag.isNotEmpty) {
        setState(() {
          if (widget.postDraft.hashtags.length < PostDraft.maxCountHashtags) {
          if (!widget.postDraft.hashtags.contains(tag)) {
            widget.postDraft.hashtags.add(tag);
          }} else {
            AppInfoDialog.show(context, "Можно добавить только 6 хештегов.");
          }
          _tagsController.clear();
        });
      }
    }
  }

  void _removeTag(String tag) {
    setState(() {
      widget.postDraft.hashtags.remove(tag);
    });
  }

  Future<void> _startPublication() async {
    if (widget.postDraft.name.isEmpty) {
      AppInfoDialog.show(context, "Название поста не должно быть пустым.");
      return;
    }

    if (widget.postDraft.previewPath == null || widget.postDraft.previewPath!.isEmpty) {
      AppInfoDialog.show(context, "Необходимо выбрать превью.");
      return;
    }

    CreatingPostService service = CreatingPostService(post: widget.postDraft);
    service.startCreating();

    if (mounted) {
      await AppInfoDialog.show(context, "Пожалуйста, не закрывайте приложение пока идет загрузка публикации.");
    }

    if (mounted) {
      final roomId = context.read<AuthProvider>().roomId;

      if (roomId != null) {
        context.go('/personalRoomPosts/$roomId');
      } else {
        context.go('/');
      }
    }
  }

  Future<void> _pickAndCropImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Обрежьте фото 16:9',
            toolbarColor: const Color(0xFFB4B4B4),
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: const Color(0xFF525252),
            backgroundColor: const Color(0xFFF5F5F5),
            initAspectRatio: CropAspectRatioPreset.ratio16x9,
            lockAspectRatio: true,
          ),
          IOSUiSettings(
            title: 'Обрежьте фото 16:9',
            aspectRatioLockEnabled: true,
          ),
        ],
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
      );

      if (croppedFile != null) {
        setState(() => widget.postDraft.previewPath = croppedFile.path);
      }
    }
  }

  Widget _buildTagsDisplay() {
    if (widget.postDraft.hashtags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: widget.postDraft.hashtags.map((tag) => _buildTagChip(tag)).toList(),
      ),
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
          Text(
            "#$tag",
            style: const TextStyle(fontFamily: 'SNPro', fontSize: 14),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF797979)),
          ),
        ],
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return GestureDetector(
  //     onTap: () => FocusScope.of(context).unfocus(),
  //     child: Scaffold(
  //       backgroundColor: const Color(0xFFF8F8F8),
  //       appBar: _buildAppBar(context),
  //       body: ListView(
  //         padding: const EdgeInsets.all(16),
  //         children: [
  //           _buildSectionTitle("Название"),
  //           // Название поста
  //           _buildCustomField(
  //             controller: _namePostController,
  //             // hint: 'Название поста',
  //           ),
  //
  //           const SizedBox(height: 20),
  //           _buildSectionTitle("Превью"),
  //           const SizedBox(height: 8),
  //           _buildImagePicker(),
  //
  //           // const SizedBox(height: 24),
  //           // _buildSectionTitle("Категория"),
  //           // const SizedBox(height: 8),
  //           // _buildCategorySelector(),
  //           //
  //           // const SizedBox(height: 24),
  //           // _buildSectionTitle("Хештеги"),
  //           // const SizedBox(height: 8),
  //           // _buildTagsDisplay(),
  //           //
  //           // TextField(
  //           //   controller: _tagsController,
  //           //   onChanged: _handleTagInput, // Привязываем обработчик
  //           //   style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
  //           //   decoration: InputDecoration(
  //           //     hintText: 'Введите тег и нажмите пробел...',
  //           //     filled: true,
  //           //     fillColor: Colors.white,
  //           //     contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //           //     enabledBorder: OutlineInputBorder(
  //           //       borderRadius: BorderRadius.circular(12),
  //           //       borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
  //           //     ),
  //           //     focusedBorder: OutlineInputBorder(
  //           //       borderRadius: BorderRadius.circular(12),
  //           //       borderSide: const BorderSide(color: Color(0xFFB4B4B4), width: 1.5),
  //           //     ),
  //           //   ),
  //           // ),
  //           //
  //           // const SizedBox(height: 24),
  //           // _buildSectionTitle("Ссылка на мастерскую"),
  //           // const SizedBox(height: 8),
  //           // _buildWorkShopBinding(),
  //
  //           const Spacer(),
  //           _buildPublishButton(),
  //           SizedBox(height: MediaQuery.of(context).padding.bottom,)
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: _buildAppBar(context),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionTitle("Название"),
                    const SizedBox(height: 8),
                    _buildCustomField(
                      controller: _namePostController,
                    ),

                    const SizedBox(height: 20),
                    _buildSectionTitle("Превью"),
                    const SizedBox(height: 8),
                    _buildImagePicker(),

                  ]),
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildPublishButton(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: context.ui.appBarColor,
      elevation: 0,
      leading: const AppBackButton(),
      title: const Text(
        'Настройка',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontFamily: 'SNPro',
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildCustomField({required TextEditingController controller}) {
    return TextField(
      controller: controller,
      style: const TextStyle(fontFamily: 'SNPro', fontSize: 16),
      decoration: InputDecoration(
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

  Widget _buildImagePicker() {
    if (widget.postDraft.previewPath == null) {
      return InkWell(
        onTap: _pickAndCropImage,
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
                "Нажмите, чтобы добавить обложку",
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
            child: Image.file(File(widget.postDraft.previewPath!), fit: BoxFit.cover),
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Row(
            children: [
              _buildCircleBtn(Icons.edit, () => _pickAndCropImage()),
              const SizedBox(width: 8),
              _buildCircleBtn(
                Icons.delete_outline,
                () => setState(() => widget.postDraft.previewPath = null),
                isRed: true,
              ),
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
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isRed ? Colors.blueGrey : const Color(0xFF424242),
          size: 20,
        ),
      ),
    );
  }

  // Widget _buildCategorySelector() {
  //   return InkWell(
  //     onTap: _showCategoryDialog,
  //     borderRadius: BorderRadius.circular(12),
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  //       decoration: BoxDecoration(
  //         color: Colors.white,
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(color: const Color(0xFFD1D1D1)),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Text(
  //             widget.postDraft.category == Categories.defaultVal
  //                 ? "Выберите категорию..."
  //                 : widget.postDraft.category.label,
  //             style: TextStyle(
  //               fontFamily: 'SNPro',
  //               fontSize: 16,
  //               color: widget.postDraft.category == Categories.defaultVal
  //                   ? Colors.black26
  //                   : Colors.black,
  //             ),
  //           ),
  //           const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  void _showCategoryDialog() {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Выберите категорию",
            style: TextStyle(
              fontFamily: 'SNPro',
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: Categories.values.length,
              itemBuilder: (context, index) {
                final category = Categories.values[index];

                if (category == Categories.defaultVal) {
                  return const SizedBox.shrink();
                }

                final bool isSelected = widget.postDraft.category == category;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  title: Text(
                    category.label,
                    style: TextStyle(
                      fontFamily: 'SNPro',
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? context.ui.primaryColor : Colors.black87,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: context.ui.primaryColor)
                      : null,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  onTap: () {
                    setState(() {
                      widget.postDraft.category = category;
                    });
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleBindLinkWorkshop() async {
    String? roomId;
    if (mounted) {
      roomId = context.read<AuthProvider>().roomId;
    }
    if (roomId == null) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось получить текущую сессию. Пожалуйста, сообщите в поддержку.");
      }
      return;
    }

    final destinationId = await context.push<String?>(
      '/select-folder-diary/$roomId',
    );

    if (destinationId != null) {
      if (mounted) {
        setState(() {
          widget.postDraft.workshopLink.setId(destinationId);
        });
      }
    }
  }

  void _onCloseLink() {
    if (mounted) {
      setState(() {
        widget.postDraft.workshopLink.setEmpty();
      });
    }
  }

  Widget _buildWorkShopBinding() {
    final bool isLinkSelected = widget.postDraft.workshopLink.isExist();

    if (isLinkSelected) {
      return CustomLinkButton(
        icon: Icons.burst_mode_outlined,
        label: "Связано с мастерской",
        onClose: _onCloseLink,
      );
    }

    return InkWell(
      onTap: _handleBindLinkWorkshop,
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
            const Text(
              "Связать с мастерской...",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black26,
              ),
            ),
            const Icon(Icons.link, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildPublishButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          _startPublication();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.ui.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.ui.radiusButtonStandard),
          ),
          elevation: 0,
        ),
        child: Text(
          "Опубликовать",
          style: TextStyle(
            color: context.ui.fontColorLight,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
