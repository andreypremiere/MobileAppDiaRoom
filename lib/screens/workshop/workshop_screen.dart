import 'dart:io';

import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/room_screen/app_dialogs.dart';
import 'package:dia_room/models/enums/workshop/creating_workshop.dart';
import 'package:dia_room/models/workshop/folder.dart';
import 'package:dia_room/models/workshop/item.dart';
import 'package:dia_room/screens/publication/full_video_screen.dart';
import 'package:dia_room/services/workshop/uploader_manager.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/workshop/create_folder_dialog_window.dart';
import '../../components/workshop/folder_widget.dart';
import '../../components/workshop/item_widget.dart';
import '../../components/workshop/rename_dialog_window.dart';
import '../../configuration/constants.dart';
import '../../contracts/workshop/responses/content.dart';
import '../../models/enums/file_type.dart';
import '../../models/enums/workshop/folder_actions.dart';
import '../../models/enums/workshop/item_actions.dart';
import '../../models/enums/workshop/item_type.dart';
import '../../utils/auth_service.dart';
import '../publication/full_image_screen.dart';

class WorkshopScreen extends StatefulWidget {
  final String roomId;
  final String? folderId;

  const WorkshopScreen({super.key, required this.roomId, this.folderId});

  @override
  State<WorkshopScreen> createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  bool isMyRoom = false;

  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _allContent = [];
  List<Item> _photos = [];

  @override
  void initState() {
    super.initState();
    final myRoomId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myRoomId;

    _loadData();
  }


  void addItem(Item item) {
    int index = _allContent.length;
    if (item.itemType == ItemType.video) {
      index = _allContent.indexWhere((element) => element is Item && element.itemType == ItemType.photo);
      if (index == -1) {
        index = _allContent.length;
      }
    }
    if (mounted) {
      setState(() {
        _allContent.insert(index, item);

        if (item.itemType == ItemType.photo) {
          _photos.add(item);
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AuthResponse response = widget.folderId == null
          ? await getRootContent(roomId: widget.roomId)
          : await getContentFolder(roomId: widget.roomId, folderId: widget.folderId!);

      if (response.success && response.data != null) {
        final Content root = Content.fromMap(response.data!);
        final folders = root.folders;
        final videos = root.items.where((i) => i.itemType == ItemType.video).toList();
        final photos = root.items.where((i) => i.itemType == ItemType.photo).toList();

        if (mounted) {
          setState(() {
            _photos = photos;
            _allContent = [...folders, ...videos, ...photos];
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response.message ?? "Не удалось загрузить данные";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Ошибка в работе приложения. Пожалуйста, обратитесь в поддержку.";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    await _loadData();
  }

  void addFolder(Folder newFolder) {
    int insertIndex = _allContent.indexWhere((element) => element is! Folder);

    if (insertIndex == -1) {
      insertIndex = _allContent.length;
    }

    if (mounted) {
      setState(() {
        _allContent.insert(insertIndex, newFolder);
      });
    }
  }

  Future<List<XFile>> _handleAddPhotos() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> images;
    try {
      images = await picker.pickMultiImage();
      return images;
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Возникла ошибка в работе сервиса выбора фотографий. Пожалуйста, обратитесь в поддержку.");
      }
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
      if (mounted) {
        await AppInfoDialog.show(context, "Возникла ошибка в работе сервиса выбора видео. Пожалуйста, обратитесь в поддержку.");
      }
      return [];
    }
  }

  Future<void> _onFolderActionSelected(FolderAction action, Folder folder) async {
    final folderIndex = _allContent.indexOf(folder);
    if (folderIndex == -1) return;

    switch (action) {
      case FolderAction.rename:
        final newName = await showRenameDialog(context, folder.name);

        if (newName != null && newName.isNotEmpty && newName != folder.name) {
          final result = await renameFolder(
            folderId: folder.id,
            newName: newName,
          );

          if (result.success) {
            if (mounted) {
              setState(() {
                _allContent[folderIndex] = folder.copyWith(
                  name: newName,
                  updatedAt: DateTime.now(),
                );
              });
            }
          } else {
            if (mounted) {
              await AppInfoDialog.show(context, result.message ?? "Не удалось переименовать папку.");
            }
          }
        }
        break;

      case FolderAction.move:
        final url = Uri(
          path: '/select-folder/${widget.roomId}/${folder.id}',
          queryParameters: {
            'filterFolders': true.toString(),
          },
        ).toString();

        final destinationId = await context.push<String?>(url);

        if (destinationId != null) {
          if (destinationId == widget.folderId) {
            if (mounted) {
              await AppInfoDialog.show(context, "Нельзя переместить папку в саму себя.");
            }
            return;
          }
          if (destinationId == "root" && widget.folderId == null) {
            if (mounted) {
              await AppInfoDialog.show(context, "Папка уже находится здесь.");
            }
            return;
          }

          String? destId;
          if (destinationId == "root") {
            destId = null;
          } else {
            destId = destinationId;
          }

          final result = await moveFolder(
            targetId: folder.id,
            destinationId: destId,
          );
          if (result.success) {
            if (mounted) {
              setState(() {
                _allContent.removeAt(folderIndex);
              });
            }
          } else {
            if (mounted) {
              await AppInfoDialog.show(context, result.message ?? "Не удалось переместить папку.");
            }
          }
        }
        break;

      case FolderAction.delete:
        bool? confirm;
        if (mounted) {
          confirm = await AppDialogs.showConfirmDialog(context, text: "Вы уверены, что хотите безвозвратно удалить папку и все ее содержимое? Это необратимая операция!", cancelText: "Отмена", confirmText: "Подтвердить");
        }

        if (confirm == true) {
          final result = await deleteFolder(folderId: folder.id);
          if (result.success) {
            if (mounted) {
              setState(() {
                _allContent.removeAt(folderIndex);
              });
            }
          } else {
            if (mounted) {
              await AppInfoDialog.show(context, result.message ?? "Не удалось удалить папку.");
            }
          }
        }
        break;
    }
  }

  Future<void> _onItemActionSelected(ItemAction action, Item item) async {
    final itemIndex = _allContent.indexOf(item);
    if (itemIndex == -1) return;

    switch (action) {
      case ItemAction.move:
        final url = Uri(
          path: '/select-folder/${widget.roomId}/${item.id}',
          queryParameters: {
            'filterFolders': false.toString(),
          },
        ).toString();

        final destinationId = await context.push<String?>(url);

        if (destinationId != null) {
          if (destinationId == widget.folderId) {
            if (mounted) {
              await AppInfoDialog.show(context, "Значение уже находится в этой папке.");
            }
            return;
          }
          if (destinationId == "root" && widget.folderId == null) {
            if (mounted) {
              await AppInfoDialog.show(context, "Значение уже находится в этой папке.");
            }
            return;
          }

          String? destId;
          if (destinationId == "root") {
            destId = null;
          } else {
            destId = destinationId;
          }

          final result = await moveItem(
            targetId: item.id!,
            destinationId: destId,
          );
          if (result.success) {
            if (mounted) {
              setState(() {
                _allContent.removeAt(itemIndex);
              });
            }
          } else {
            if (mounted) {
              await AppInfoDialog.show(context, result.message ?? "Не удалось переместить значение.");
            }
          }
        }
        break;

      case ItemAction.delete:
        bool? confirm;
        if (mounted) {
          confirm = await AppDialogs.showConfirmDialog(context, text: "Вы уверены, что хотите удалить?", cancelText: "Отмена", confirmText: "Подтвердить");
        }

        if (confirm == true) {
          final result = await deleteItem(itemId: item.id!);
          if (result.success) {
            if (mounted) {
              setState(() {
                _allContent.removeAt(itemIndex);
              });
            }
          } else {
            if (mounted) {
              await AppInfoDialog.show(context, result.message ?? "Не удалось удалить значение.");
            }
          }
        }
        break;
    }
  }

  Widget _buildBody() {
    // Ошибка (сеть/сервер) при пустом списке
    if (!_isLoading && _errorMessage != null && _allContent.isEmpty) {
      return DiaRoomErrorView(
        errorMessage: _errorMessage!,
        onRefresh: _handleRefresh,
      );
    }

    // 2. Первичная загрузка
    if (_isLoading && _allContent.isEmpty) {
      return const Center(child: DiaRoomLoader());
    }

    // 3. Успешный ответ, но папка пуста
    if (!_isLoading && _allContent.isEmpty) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        color: context.ui.primaryColor,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
            Center(
              child: Text(
                _errorMessage ?? "Тут пока пусто",
                style: TextStyle(color: context.ui.fontColorHint),
              ),
            ),
          ],
        ),
      );
    }

    // 4. Отображение контента
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: context.ui.primaryColor,
      child: GridView.builder(
        physics: const AlwaysScrollableScrollPhysics(), // Разрешает pull-to-refresh даже если контента мало
        padding: EdgeInsets.only(
          top: 8,
          left: 8,
          right: 8,
          bottom: MediaQuery.of(context).padding.bottom + 8,
        ),
        itemCount: _allContent.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final item = _allContent[index];
          if (item is Folder) {
            return FolderItem(
              canEdit: isMyRoom,
              folder: item,
              onTap: () => context.push('/workshop/${widget.roomId}/${item.id}'),
              onActionSelected: (action) => _onFolderActionSelected(action, item),
            );
          }
          if (item is Item) {
            return FileItem(
              canEdit: isMyRoom,
              item: item,
              onTap: () {
                switch (item.itemType) {
                  case ItemType.photo:
                    final int photoIndex = _photos.indexOf(item);
                    final photoUrls = _photos
                        .where((i) => i.payload is PhotoPayload)
                        .map((i) => getFullUrl((i.payload as PhotoPayload).publicUrl ?? ''))
                        .toList();

                    if (photoIndex != -1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullImageScreen(
                            imageUrls: photoUrls,
                            initialIndex: photoIndex,
                            type: FileType.network,
                          ),
                        ),
                      );
                    }
                    break;

                  case ItemType.video:
                    final payload = item.payload as VideoPayload;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenVideoScreen(
                          videoUrl: getFullUrl(payload.publicUrl ?? ""),
                          type: FileType.network,
                        ),
                      ),
                    );
                    break;
                }
              },
              onActionSelected: (action) => _onItemActionSelected(action, item),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.add_rounded,
                  size: context.ui.iconSizePanel,
                  color: context.ui.iconColorPrimary,
                ),
              ),
              onSelected: (action) async {
                switch (action) {
                  case CreatingWorkshopAction.folder:
                    await showCreateFolderDialog(
                      context,
                      roomId: widget.roomId,
                      parentId: widget.folderId,
                      onSuccess: addFolder,
                    );
                    break;

                  case CreatingWorkshopAction.photo:
                    final List<XFile> pathPhotos = await _handleAddPhotos();
                    if (pathPhotos.isNotEmpty) {
                      List<XFile> filteredPhotos = pathPhotos;

                      if (pathPhotos.length > limitPhotosForLoadInWorkshop) {
                        filteredPhotos = pathPhotos.sublist(0, limitPhotosForLoadInWorkshop); // Используем правильную константу

                        if (context.mounted) {
                          AppInfoDialog.show(
                              context,
                              "За раз можно загрузить не более $limitPhotosForLoadInWorkshop фотографий. Будут загружены $limitPhotosForLoadInWorkshop первых фотографий."
                          );
                        }
                      }

                      if (context.mounted) {
                        AppInfoDialog.show(context, "Пожалуйста, не закрывайте приложения во время загрузки.");
                        final manager = context.read<UploaderManager>();
                        manager.uploadPhotos(files: filteredPhotos, folderId: widget.folderId, addPhoto: addItem);
                      }
                    }
                    break;

                  case CreatingWorkshopAction.video:
                    final List<XFile> pathVideos = await _handleAddVideos();
                    if (pathVideos.isNotEmpty) {
                      List<XFile> filteredVideos = pathVideos;

                      if (pathVideos.length > limitVideosForLoadInWorkshop) {
                        filteredVideos = pathVideos.sublist(0, limitVideosForLoadInWorkshop); // Используем правильную константу

                        if (context.mounted) {
                          AppInfoDialog.show(
                              context,
                              "За раз можно загрузить не более $limitVideosForLoadInWorkshop видео. Будут загружены $limitVideosForLoadInWorkshop первых видео."
                          );
                        }
                      }

                      bool hasLargeVideos = false;

                      for (var file in filteredVideos) {
                        final size = await File(file.path).length();
                        if (size > limitSizeForVideoInWorkshop) {
                          hasLargeVideos = true;
                          break;
                        }
                      }

                      if (hasLargeVideos) {
                        if (context.mounted) {
                          AppInfoDialog.show(
                              context,
                              "Видео с размером больше ${limitSizeForVideoInWorkshop / (1024 *1024)} МБ. не будут загружены."
                          );
                        }
                      }

                      if (context.mounted) {
                        AppInfoDialog.show(context, "Пожалуйста, не закрывайте приложения во время загрузки.");
                        final manager = context.read<UploaderManager>();
                        manager.uploadVideos(files: filteredVideos, folderId: widget.folderId, addItem: addItem);
                      }
                    }

                    break;
                }
              },
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
      body: Column(
        children: [
          // Прогресс бар загрузки (если активен UploaderManager)
          Consumer<UploaderManager>(
            builder: (context, manager, child) {
              if (!manager.isUploading) return const SizedBox.shrink();
              return Column(
                children: [
                  LinearProgressIndicator(
                    value: manager.progress,
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

          // Основной контент (Grid, Loader, ErrorView или Пустота)
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }
}