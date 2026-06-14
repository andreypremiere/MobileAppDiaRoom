import 'package:dia_room/components/loading_widget/error_widget.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
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
  bool _isLoading = true;
  String? _errorMessage;
  List<Folder> _folders = [];

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final AuthResponse response = widget.currentFolderId == null
          ? await getRootFolders(roomId: widget.roomId)
          : await getFolders(roomId: widget.roomId, folderId: widget.currentFolderId!);

      if (response.success && response.data != null) {
        final Content root = Content.fromMap(response.data!);

        List<Folder> fetchedFolders = root.folders;
        if (widget.filterFolders) {
          fetchedFolders = fetchedFolders.where((f) => f.id != widget.targetId).toList();
        }

        if (mounted) {
          setState(() {
            _folders = fetchedFolders;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = response.message ?? "Не удалось загрузить папки.";
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

  Widget _buildBody() {
    //  Состояние ошибки
    if (!_isLoading && _errorMessage != null) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _loadFolders,
        ),
      );
    }

    // 2. Состояние загрузки
    if (_isLoading) {
      return const Center(child: DiaRoomLoader());
    }

    // 3. Пустая папка
    if (_folders.isEmpty) {
      return Center(
        child: Text(
          'Тут пусто.',
          style: TextStyle(color: context.ui.fontColorHint),
        ),
      );
    }

    return FolderGridView(
      folders: _folders,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: context.ui.appBarColor,
        title: Text('Выберите место'),
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
      body: _buildBody(),
    );
  }
}