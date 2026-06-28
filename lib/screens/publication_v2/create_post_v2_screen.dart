import 'dart:io';
import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/auth_service.dart';
import '../../components/diary/link_button.dart';
import '../../components/general/app_back_button.dart';
import '../../components/info_dialog_component.dart';
import '../../configuration/constants.dart';
import '../../models/post_v2/post_v2_draft.dart';
import '../../services/post_v2/post_v2_uploader_manager.dart';

class CreateInstagramPostScreen extends StatefulWidget {
  const CreateInstagramPostScreen({super.key});

  @override
  State<CreateInstagramPostScreen> createState() => _CreateInstagramPostScreenState();
}

class _CreateInstagramPostScreenState extends State<CreateInstagramPostScreen> {
  final PostV2Draft _postDraft = PostV2Draft();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  bool _isPublication = false;

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(() {
      _postDraft.description = _descriptionController.text;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickMultiImages() async {
    final int currentCount = _postDraft.imagesPaths.length;
    if (currentCount >= maxImagesPostV2) {
      AppInfoDialog.show(context, "Можно добавить не более ${maxImagesPostV2} фотографий.");
      return;
    }

    final List<XFile> pickedFiles = await _picker.pickMultiImage(
      imageQuality: 85,
    );

    if (pickedFiles.isNotEmpty) {
      final int availableSlots = maxImagesPostV2 - currentCount;
      final int imagesToAdd = pickedFiles.length > availableSlots ? availableSlots : pickedFiles.length;

      setState(() {
        for (int i = 0; i < imagesToAdd; i++) {
          _postDraft.imagesPaths.add(pickedFiles[i].path);
        }
      });

      if (pickedFiles.length > availableSlots) {
        AppInfoDialog.show(
          context,
          "Было добавлено только $availableSlots фото, так как максимальное количество в карусели — $maxImagesPostV2.",
        );
      }
    }
  }

  Future<void> _editSpecificImage(int index) async {
    final String targetPath = _postDraft.imagesPaths[index];

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: targetPath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Редактирование фото',
          toolbarColor: const Color(0xFFB4B4B4),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF525252),
          backgroundColor: const Color(0xFFF5F5F5),
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Редактирование фото',
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (croppedFile != null) {
      setState(() {
        _postDraft.imagesPaths[index] = croppedFile.path;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _postDraft.imagesPaths.removeAt(index);
    });
  }

  void _handleTagInput(String value) {
    if (value.endsWith(' ') || value.endsWith(',')) {
      String tag = value.replaceAll(',', '').replaceAll('#', '').trim();

      if (tag.isNotEmpty) {
        setState(() {
          if (_postDraft.hashtags.length < maxHashtagsPostV2) {
            if (!_postDraft.hashtags.contains(tag)) {
              _postDraft.hashtags.add(tag);
            }
          } else {
            AppInfoDialog.show(context, "Можно добавить только $maxHashtagsPostV2 хештегов.");
          }
          _tagsController.clear();
        });
      }
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _postDraft.hashtags.remove(tag);
    });
  }

  Future<void> _handleBindLinkWorkshop() async {
    final roomId = context.read<AuthProvider>().roomId;
    if (roomId == null) return;

    final destinationId = await context.push<String?>('/select-folder-diary/$roomId');
    if (destinationId != null) {
      setState(() {
        _postDraft.workshopLinkId = destinationId;
      });
    }
  }


  Future<void> _handleBindLinkArticle() async {
    if (mounted) {
      final postId = await context.push<String?>('/select_post_diary');

      if (postId != null) {
        setState(() {
          _postDraft.articleLinkId = postId;
        });
      }
    }
  }

  Future<void> _submitPublication() async {
    if (_postDraft.imagesPaths.isEmpty) {
      if (mounted) {
        await AppInfoDialog.show(context, "Добавьте хотя бы одну фотографию для публикации.");
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isPublication = true;
      });
    }

    AuthResponse result;

    try {
      final manager = PostV2UploaderManager();
      result = await manager.createPost(_postDraft);
    } catch (e) {
      print("Возникла ошибка $e");
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isPublication = false;
        });
      }
    }

    if (mounted && result.success) {
      context.pop(result.data);
    }
    if (mounted && !result.success) {
      await AppInfoDialog.show(context, result.message ?? "Не удалось опубликовать пост");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F8F8),
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          elevation: 0,
          leading: const AppBackButton(),
          title: const Text(
            'Новая публикация',
          ),
        ),
        body: _isPublication ? Center(child: DiaRoomLoader(),) : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Фотографии (${_postDraft.imagesPaths.length}/$maxImagesPostV2)"),
            const SizedBox(height: 10),
            _buildMediaCarousel(),

            const SizedBox(height: 14),
            _buildSectionTitle("Описание"),
            const SizedBox(height: 10),
            _buildDescriptionField(),

            const SizedBox(height: 14),
            _buildSectionTitle("Хештеги"),
            const SizedBox(height: 10),
            _buildTagsSection(),

            const SizedBox(height: 14),

            _buildSectionTitle("Добавить каталог"),
            const SizedBox(height: 10),
            _buildWorkshopSection(),

            const SizedBox(height: 14),
            _buildSectionTitle("Добавить статью"),
            const SizedBox(height: 10),
            _buildArticleSection(),

            const SizedBox(height: 20),
            _buildPublishButton(),
            SizedBox(height: MediaQuery.of(context).padding.bottom)
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(
            fontSize: 16,
            fontFamily: 'SNPro',
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D2D2D)
        ),
      ),
    );
  }

  Widget _buildMediaCarousel() {
    final bool showAddButton = _postDraft.imagesPaths.length < maxImagesPostV2;

    return SizedBox(
      height: 120,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        proxyDecorator: (Widget child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              return Material(
                elevation: 0,
                color: Colors.transparent,
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (showAddButton && (oldIndex == 0 || newIndex == 0)) return;
            int adjustedOldIndex = showAddButton ? oldIndex - 1 : oldIndex;
            int adjustedNewIndex = showAddButton ? newIndex - 1 : newIndex;
            if (oldIndex < newIndex) adjustedNewIndex -= 1;
            final String item = _postDraft.imagesPaths.removeAt(adjustedOldIndex);
            _postDraft.imagesPaths.insert(adjustedNewIndex, item);
          });
        },
        itemCount: showAddButton ? _postDraft.imagesPaths.length + 1 : _postDraft.imagesPaths.length,
        itemBuilder: (context, index) {
          final Key itemKey = ValueKey(showAddButton && index == 0 ? "add_btn" : _postDraft.imagesPaths[showAddButton ? index - 1 : index]);

          if (showAddButton && index == 0) {
            return GestureDetector(
              key: itemKey,
              onTap: _pickMultiImages,
              child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
                ),
                child: const Icon(Icons.add_a_photo_outlined, size: 32, color: Colors.grey),
              ),
            );
          }

          final int imageIndex = showAddButton ? index - 1 : index;
          final String imagePath = _postDraft.imagesPaths[imageIndex];

          return Container(
            key: itemKey,
            width: 120,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () => _editSpecificImage(imageIndex),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: FileImage(File(imagePath)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: GestureDetector(
                      onTap: () => _removeImage(imageIndex),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      maxLines: 4,
      maxLength: maxDescriptionSymbolsPost,
      style: const TextStyle(fontFamily: 'SNPro', fontSize: 15),
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText: 'Добавьте подпись к публикации...',
        filled: true,
        fillColor: Colors.white,
        counterText: "",
        contentPadding: const EdgeInsets.all(16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: context.ui.primaryColor, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_postDraft.hashtags.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 6.0,
            children: _postDraft.hashtags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('#$tag', style: const TextStyle(fontFamily: 'SNPro', fontSize: 14, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => _removeTag(tag),
                    child: const Icon(Icons.clear, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 10),
        ],
        TextField(
          controller: _tagsController,
          onChanged: _handleTagInput,
          style: const TextStyle(fontFamily: 'SNPro', fontSize: 15),
          decoration: InputDecoration(
            hintText: 'Добавить тег (через пробел)...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: context.ui.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkshopSection() {
    final bool isLinkSelected = _postDraft.workshopLinkId != null;

    if (isLinkSelected) {
      return CustomLinkButton(
        icon: Icons.burst_mode_outlined,
        label: "Каталог",
        onClose: () => setState(() => _postDraft.workshopLinkId = null),
      );
    }

    return InkWell(
      onTap: _handleBindLinkWorkshop,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Выбрать каталог", style: TextStyle(fontSize: 15, color: Colors.black26)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleSection() {
    final bool isLinkSelected = _postDraft.articleLinkId != null;

    if (isLinkSelected) {
      return CustomLinkButton(
        icon: Icons.article_outlined,
        label: "Статья",
        onClose: () => setState(() => _postDraft.articleLinkId = null),
      );
    }

    return InkWell(
      onTap: _handleBindLinkArticle,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Выбрать статью", style: TextStyle(fontSize: 15, color: Colors.black26)),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
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
        onPressed: _submitPublication,
        style: ElevatedButton.styleFrom(
          backgroundColor: context.ui.primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.ui.radiusButtonStandard)),
          elevation: 0,
        ),
        child: Text(
          "Опубликовать пост",
          style: TextStyle(color: context.ui.fontColorLight, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}