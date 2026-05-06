import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/models/enums/workshop/creating_workshop.dart';
import 'package:dia_room/models/workshop/folder.dart';
import 'package:dia_room/models/workshop/item.dart';
import 'package:dia_room/services/workshop/uploader_manager.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/workshop/create_folder_dialog_window.dart';
import '../../components/workshop/folder_widget.dart';
import '../../components/workshop/item_widget.dart';
import '../../components/workshop/rename_dialog_window.dart';
import '../../contracts/workshop/responses/content.dart';
import '../../models/enums/workshop/folder_actions.dart';
import '../../models/enums/workshop/item_actions.dart';
import '../../utils/auth_service.dart';

class WorkshopScreen extends StatefulWidget {
  final String roomId;
  final String? folderId;

  const WorkshopScreen({super.key, required this.roomId, this.folderId});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  late Future<AuthResponse> _workshopFuture;
  bool isMyRoom = false;

  @override
  void initState() {
    super.initState();
    final myRoomId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myRoomId;

    _loadData();
  }

  void _loadData() {
    setState(() {
      if (widget.folderId == null) {
        _workshopFuture = getRootContent(roomId: widget.roomId);
      } else {
        _workshopFuture = getContentFolder(
          roomId: widget.roomId,
          folderId: widget.folderId!,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    _loadData();
    await _workshopFuture;
  }

  Future<List<XFile>> _handleAddPhotos() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> images;
    try {
      images = await picker.pickMultiImage(limit: 20);
      return images;
    } catch (e) {
      print("Ошибка при выборе нескольких изображений: $e");
      return [];
    }
  }

  Future<List<XFile>> _handleAddVideos() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> videos;
    try {
      videos = await picker.pickMultiVideo(limit: 5);
      return videos;
    } catch (e) {
      print("Ошибка при выборе нескольких изображений: $e");
      return [];
    }
  }

  Future<void> _onFolderActionSelected(FolderAction action, Folder folder) async {
    switch (action) {
      case FolderAction.rename:
        final newName = await showRenameDialog(context, folder.name);

        if (newName != null && newName.isNotEmpty && newName != folder.name) {
          final result = await renameFolder(
            folderId: folder.id,
            newName: newName,
          );

          if (result.success) {
            _handleRefresh();
          } else {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.message ?? "Ошибка при сохранении")),
            );
          }
        }
        break;

      case FolderAction.move:
        final destinationId = await context.push<String?>(
          '/select-folder/${widget.roomId}/${folder.id}',
        );

        if (destinationId != null && destinationId != 'cancel') {
          if (destinationId == widget.folderId) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Папка уже находится здесь')),
            );
            break;
          }

          final result = await moveFolder(
            targetId: folder.id,
            destinationId: destinationId,
          );
          if (result.success) {
            _handleRefresh();
          }
        }
        break;

      case FolderAction.delete:
        print("Логика удаления для ${folder.id}");
        break;
    }
  }

  Future<void> _onItemActionSelected(ItemAction action, Item item) async {
    switch (action) {
      case ItemAction.move:
        final destinationId = await context.push<String?>(
          '/select-folder/${widget.roomId}/${item.id}',
        );

        if (destinationId != null && destinationId != 'cancel') {
          if (destinationId == widget.folderId) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Файл уже находится в этой папке')),
            );
            break;
          }

          // final result = await moveItem(
          //   targetId: item.id,
          //   destinationId: destinationId == 'root' ? null : destinationId,
          // );
          //
          // if (result.success) {
          //   _handleRefresh();
          // } else {
          //   if (!mounted) return;
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(content: Text(result.message ?? "Ошибка при перемещении")),
          //   );
          // }
        }
        break;

      case ItemAction.delete:
        // final confirm = await showDialog<bool>(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     title: const Text('Удалить файл?'),
        //     content: Text('Вы уверены, что хотите удалить «${item.itemData.title}»?'),
        //     actions: [
        //       TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
        //       TextButton(
        //         onPressed: () => Navigator.pop(context, true),
        //         child: const Text('Удалить', style: TextStyle(color: Colors.red)),
        //       ),
        //     ],
        //   ),
        // );
        //
        // if (confirm == true) {
        //   final result = await deleteItem(itemId: item.itemData.id);
        //   if (result.success) {
        //     _handleRefresh();
        //   } else {
        //     if (!mounted) return;
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(content: Text(result.message ?? "Ошибка при удалении")),
        //     );
        //   }
        // }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: const AppBackButton(),
        title: Text(
          'Мастерская',
          style: TextStyle(color: context.ui.fontColorPrimary),
        ),
        actions: [
          if (isMyRoom)
            PopupMenuButton<CreatingWorkshopAction>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: context.ui.containerColor,
              elevation: 5,
              offset: const Offset(0, 50),
              // Немного опускаем меню вниз

              // Кастомизированный вид кнопки
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.add_rounded,
                  size: context.ui.iconSizePanel,
                  color: context.ui.iconColorPrimary,
                ),
              ),

              // Логика выбора
              onSelected: (action) async {
                switch (action) {
                  case CreatingWorkshopAction.folder:
                    showCreateFolderDialog(
                      context,
                      roomId: widget.roomId,
                      parentId: widget.folderId,
                      onSuccess: _handleRefresh,
                    );
                    break;

                  case CreatingWorkshopAction.photo:
                    final List<XFile> pathPhotos = await _handleAddPhotos();
                    final manager = context.read<UploaderManager>();

                    final result = await manager.uploadPhotos(files: pathPhotos, folderId: widget.folderId);
                    _handleRefresh();
                    print('compressedImages: $result');
                    break;

                  case CreatingWorkshopAction.video:
                    final List<XFile> pathVideos = await _handleAddVideos();
                    final manager = context.read<UploaderManager>();
                    final result = await manager.uploadVideos(files: pathVideos, folderId: widget.folderId);
                    _handleRefresh();
                    print('compressedImages: $result');
                    break;
                }
              },

              // Генерация элементов меню
              itemBuilder: (context) => CreatingWorkshopAction.values
                  .map(
                    (action) => PopupMenuItem<CreatingWorkshopAction>(
                  value: action,
                  height: 44,
                  child: Row(
                    children: [
                      Icon(
                        action.icon,
                        color: context.ui.fontColorPrimary,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        action.label,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: context.ui.fontColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
                  .toList(),
            ),
        ],
      ),
      body: Column(children: [Consumer<UploaderManager>(
        builder: (context, manager, child) {
          if (!manager.isUploading) return const SizedBox.shrink();
          return Column(
            children: [
              LinearProgressIndicator(
                value: manager.progress, // <-- передаем наше значение (0.0 - 1.0)
                color: context.ui.primaryColor,
                backgroundColor: context.ui.primaryColor.withAlpha(20),
                minHeight: 4,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                child: Text(
                  "Загрузка: ${(manager.progress * 100).toInt()}%",
                  style: TextStyle(fontSize: 10, color: context.ui.fontColorHint),
                ),
              ),
            ],
          );
        },
      ),
        Expanded(child: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: context.ui.primaryColor,
        child: FutureBuilder<AuthResponse>(
          future: _workshopFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                (snapshot.hasData && !snapshot.data!.success)) {
              return Center(
                child: Text(
                  'Ошибка: ${snapshot.data?.message ?? "Не удалось загрузить данные"}',
                ),
              );
            }

            final Content root = Content.fromMap(snapshot.data!.data);
              final allContent = [...root.folders, ...root.items];

            if (allContent.isEmpty) {
              return const Center(child: Text('Тут пока пусто'));
            }

            // Ленивая загрузка через GridView.builder
            return GridView.builder(
              padding: EdgeInsets.only(top: 8, left: 8, right: 8, bottom: MediaQuery.of(context).padding.bottom + 8),
              itemCount: allContent.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final item = allContent[index];
                if (item is Folder) {
                  final folder = item;
                  return FolderItem(
                    canEdit: isMyRoom,
                    folder: folder,
                    onTap: () =>
                        context.push('/workshop/${widget.roomId}/${folder.id}'),
                    onActionSelected: (action) => _onFolderActionSelected(action, folder),
                  );
                }
                if (item is Item) {
                  return FileItem(canEdit: isMyRoom, item: item, onTap: () { print("Нажатие"); }, onActionSelected: (action) => _onItemActionSelected(action, item),

                  );
                }
                return SizedBox.shrink();
              },
            );
          },
        ),
      ),)])
    );
  }
}