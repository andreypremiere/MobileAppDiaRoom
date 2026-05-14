// ЭТО ОДИНАКОВЫЙ ФАЙЛ С screens/workshop/select_folder_screen
// ОБЯЗАТЕЛЬНО СДЕЛАТЬ РЕФАКТОРИНГ

import 'package:dia_room/components/new_public_post/app_bar_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../api/auth_response.dart';
import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/general/full_width_button.dart';
import '../../components/workshop/folder_grid_view.dart';
import '../../configuration/constants.dart';
import '../../contracts/workshop/responses/content.dart';

class SelectFolderDiaryScreen extends StatefulWidget {
  final String roomId;
  final String? currentFolderId;

  const SelectFolderDiaryScreen({
    super.key,
    required this.roomId,
    this.currentFolderId,
  });

  @override
  State<SelectFolderDiaryScreen> createState() => _SelectFolderScreenState();
}

class _SelectFolderScreenState extends State<SelectFolderDiaryScreen> {
  late Future<AuthResponse> _foldersFuture;

  @override
  void initState() {
    super.initState();
    if (widget.currentFolderId == null) {
      _foldersFuture = getRootFolders(roomId: widget.roomId);
    } else {
      _foldersFuture = getFolders(
        roomId: widget.roomId,
        folderId: widget.currentFolderId!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.ui.appBarColor,
        title: Text(
          'Выберите папку',
          style: TextStyle(color: context.ui.fontColorPrimary),
        ),
        leading: widget.currentFolderId != null
            ? AppBackButton(onPressed: () => context.pop())
            : null,
        actions: [
          if (widget.currentFolderId == null)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: AppBarButton(
                text: "Отмена",
                onPressed: () => context.pop(),
                backgroundColor: context.ui.toolbarContainerColor,
              ),
            ),
        ],
      ),
      // Кнопка подтверждения
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FullWidthButton(
            text: 'Выбрать',
            onPressed: () {
              if (widget.currentFolderId == null) {
                context.pop(uuidNil);
              } else {
                context.pop(widget.currentFolderId);
              }
            },
          ),
        ),
      ),
      body: FutureBuilder<AuthResponse>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.data!.success) {
            return const Center(child: Text('Ошибка'));
          }

          final Content root = Content.fromMap(snapshot.data!.data);

          // ВАЖНО: Фильтруем список, чтобы нельзя было переместить папку саму в себя
          final safeFolders = root.folders;

          // Переиспользуем твой грид, но отключаем контекстные меню!
          return FolderGridView(
            folders: safeFolders,
            isMyRoom: false,
            onActionSelected: (_, __) {},
            onFolderTap: (folder) {
              context
                  .push<String?>(
                    '/select-folder-diary/${widget.roomId}/${folder.id}',
                  )
                  .then((result) {
                    if (result != null) context.pop(result);
                  });
            },
          );
        },
      ),
    );
  }
}
