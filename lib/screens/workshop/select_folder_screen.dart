import 'package:dia_room/components/new_public_post/app_bar_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../api/auth_response.dart';
import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/general/full_width_button.dart';
import '../../components/workshop/folder_grid_view.dart';
import '../../contracts/workshop/responses/content.dart';
import '../../models/workshop/folder.dart';

class SelectFolderScreen extends StatefulWidget {
  final String roomId;
  final String? currentFolderId;
  final String targetId;
  final bool filterFolders;

  const SelectFolderScreen({
    super.key,
    required this.roomId,
    this.currentFolderId,
    required this.targetId,
    required this.filterFolders,
  });

  @override
  State<SelectFolderScreen> createState() => _SelectFolderScreenState();
}

class _SelectFolderScreenState extends State<SelectFolderScreen> {
  late Future<AuthResponse> _foldersFuture;

  @override
  void initState() {
    super.initState();
    if (widget.currentFolderId == null) {
      _foldersFuture = getRootFolders(roomId: widget.roomId);
    } else {
      _foldersFuture = getFolders(roomId: widget.roomId, folderId: widget.currentFolderId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.ui.appBarColor,
        title: Text('Выберите место', style: TextStyle(color: context.ui.fontColorPrimary),),
        leading: AppBackButton(onPressed: () => context.pop()),
      ),
      // Кнопка подтверждения
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
          FullWidthButton(text: 'Переместить сюда', onPressed: () {
            if (widget.currentFolderId == null) {
              context.pop('root');
            } else {
              context.pop(widget.currentFolderId);
            }
          },),
        ),
      ),
      body: FutureBuilder<AuthResponse>(
        future: _foldersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError || !snapshot.data!.success) return const Center(child: Text('Ошибка'));

          final Content root = Content.fromMap(snapshot.data!.data);

          List<Folder> safeFolders;
          safeFolders = widget.filterFolders ? root.folders.where((f) => f.id != widget.targetId).toList() : root.folders;

          // Переиспользуем твой грид, но отключаем контекстные меню!
          return FolderGridView(
            folders: safeFolders,
            isMyRoom: false,
            onActionSelected: (_, __) {},
            onFolderTap: (folder) {
              final url = Uri(
                path: '/select-folder/${widget.roomId}/${widget.targetId}/${folder.id}',
                queryParameters: {
                  'filterFolders': widget.filterFolders.toString(),
                },
              ).toString();
              context.push<String?>(url).then((result) {
                if (context.mounted && result != null) context.pop(result);
              });
            },
          );
        },
      ),
    );
  }
}