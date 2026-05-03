import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/components/workshop/folder_grid_view.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
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
        title: const Text('Мастерская'),
        actions: [
          if (isMyRoom)
            IconButton(
              onPressed: () => _showCreateDialog(context),
              icon: Icon(
                Icons.add_rounded,
                size: context.ui.iconSizePanel,
                color: context.ui.iconColorPrimary,
              ),
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

                    // Если пользователь нажал "Сохранить" и имя не пустое
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
                    print("Логика перемещения для ${folder.id}");
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

  void _showCreateDialog(BuildContext context) {
    print("Создание новой папки");
  }
}
