import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/components/workshop/folder_grid_view.dart';
import 'package:dia_room/models/enums/creating_workshop.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/workshop/create_folder_dialog_window.dart';
import '../../components/workshop/rename_dialog_window.dart';
import '../../contracts/workshop/responses/root.dart';
import '../../models/enums/folder_actions.dart';
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
        _workshopFuture = getRoomRoot(roomId: widget.roomId);
      } else {
        _workshopFuture = getFolder(folderId: widget.folderId!);
      }
    });
  }

  Future<void> _handleRefresh() async {
    _loadData();
    await _workshopFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: const AppBackButton(),
        title: Text('Мастерская',  style: TextStyle(color: context.ui.fontColorPrimary),),
        actions: [
          if (isMyRoom)
            PopupMenuButton<CreatingWorkshopAction>(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: context.ui.containerColor,
              elevation: 5,
              offset: const Offset(0, 50), // Немного опускаем меню вниз

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
              onSelected: (action) {
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
                    print("Создание фото");
                    break;
                  case CreatingWorkshopAction.video:
                    print("Создание видео");
                    break;
                }
              },

              // Генерация элементов меню
              itemBuilder: (context) => CreatingWorkshopAction.values.map((action) => PopupMenuItem<CreatingWorkshopAction>(
                value: action,
                height: 44,
                child: Row(
                  children: [
                    Icon(action.icon, color: context.ui.fontColorPrimary, size: 22),
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
              )).toList(),
            ),
        ],
      ),
      body: RefreshIndicator(
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

            final Root root = Root.fromMap(snapshot.data!.data);

            if (root.folders.isEmpty) {
              return const Center(child: Text('Тут пока пусто'));
            }

            // Ленивая загрузка через GridView.builder
            return FolderGridView(
              folders: root.folders,
              onFolderTap: (folder) => context.push('/workshop/${widget.roomId}/${folder.id}'),
              onActionSelected: (folder, action) async {
                switch (action) {
                  case FolderAction.rename:
                    final newName = await showRenameDialog(context, folder.name);

                    if (newName != null && newName.isNotEmpty && newName != folder.name) {
                      final result = await renameFolder(folderId: folder.id, newName: newName);

                      if (result.success) {
                        _handleRefresh();
                      } else {
                        // Показываем ошибку
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(result.message ?? "Ошибка при сохранении")),
                        );
                      }
                    }
                    break;
                  case FolderAction.move:
                    // Открываем экран выбора
                    final destinationId = await context.push<String?>(
                        '/select-folder/${widget.roomId}/${folder.id}'
                    );

                    print('Пришел ответ: $destinationId');

                    // Если пользователь не нажал "Отмена" (назад), а выбрал место
                    if (destinationId != 'cancel') {
                      // Запрещаем перемещение в ту же папку, где мы сейчас
                      if (destinationId == widget.folderId) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Папка уже находится здесь')));
                        break;
                      }

                      final result = await moveFolder(targetId: folder.id, destinationId: destinationId);
                      if (result.success) {
                        _handleRefresh();
                      } else {
                      }
                    }
                    break;
                  case FolderAction.delete:
                    print("Логика удаления для ${folder.id}");
                    break;
                }
              },
              isMyRoom: isMyRoom,
            );
          },
        ),
      ),
    );
  }
}
