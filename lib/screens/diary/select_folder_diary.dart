// ЭТО ОДИНАКОВЫЙ ФАЙЛ С screens/workshop/select_folder_screen
// ОБЯЗАТЕЛЬНО СДЕЛАТЬ РЕФАКТОРИНГ

import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/loading_widget/error_widget.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:dia_room/components/new_public_post/app_bar_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../api/auth_response.dart';
import '../../api/workshop_api.dart';
import '../../components/general/app_back_button.dart';
import '../../components/general/full_width_button.dart';
import '../../components/workshop/folder_grid_view.dart';
import '../../configuration/constants.dart';
import '../../contracts/workshop/responses/content.dart';
import '../../models/workshop/folder.dart';

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
  bool _isLoading = false;
  String? _errorMessage;
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final AuthResponse response;

      if (widget.currentFolderId == null) {
        response = await getRootFolders(roomId: widget.roomId);
      } else {
        response = await getFolders(
          roomId: widget.roomId,
          folderId: widget.currentFolderId!,
        );
      }

      if (!mounted) return;

      // Проверяем бизнес-логику ответа бэкенда
      if (response.success) {
        final Content root = Content.fromMap(response.data);
        setState(() {
          _folders = root.folders;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message ?? "Не удалось загрузить папки";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      _errorMessage = "Ошибка в работе приложения";
      await AppInfoDialog.show(context, "Ошибка во время работы приложения. Пожалуйста, обратитесь в поддержку.");
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
        ),
        leading: AppBackButton(onPressed: () => context.pop()),
      ),
      // Кнопка подтверждения
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FullWidthButton(
            text: 'Выбрать',
            onPressed: (_isLoading || _errorMessage != null)
                ? () {} // Блокируем кнопку во время загрузки или при ошибке
                : () {
              if (widget.currentFolderId == null) {
                context.pop(uuidNil);
              } else {
                context.pop(widget.currentFolderId);
              }
            },
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // СОСТОЯНИЕ ОШИБКИ
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _loadFolders,
        ),
      );
    }

    //  СОСТОЯНИЕ ЗАГРУЗКИ
    if (_isLoading) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // ПУСТОЙ РЕЗУЛЬТАТ
    if (_folders.isEmpty) {
      return const Center(
        child: Text(
          "Тут пусто",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // ОСНОВНОЙ КОНТЕНТ (Данные успешно загружены)
    return FolderGridView(
      folders: _folders,
      isMyRoom: false,
      onActionSelected: (_, __) {},
      onFolderTap: (folder) {
        context
            .push<String?>(
          '/select-folder-diary/${widget.roomId}/${folder.id}',
        )
            .then((result) {
          if (result != null && mounted) context.pop(result);
        });
      },
    );
  }
}
