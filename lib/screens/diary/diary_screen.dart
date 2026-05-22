import 'dart:io';

import 'package:dia_room/components/general/author_tile_appbar/author_error_tile.dart';
import 'package:dia_room/components/general/author_tile_appbar/author_loading_tile.dart';
import 'package:dia_room/components/general/author_tile_appbar/author_tile.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/message_action.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/account_api.dart';
import '../../api/diary_api.dart';
import '../../components/diary/diary_link_picker.dart';
import '../../components/diary/input_panel.dart';
import '../../components/diary/message_card.dart';
import '../../components/diary/tag_picker_window.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../configuration/constants.dart';
import '../../models/diary/selected_media.dart';
import '../../models/diary/tag.dart';
import '../../models/enums/diary/attachment_type.dart';
import '../../models/enums/diary/creating_actions.dart';
import '../../models/enums/diary/link_objects.dart';
import '../../models/enums/diary/message_type.dart';
import '../../models/post_view/author.dart';
import '../../services/diary/diary_utils.dart';
import '../../services/diary/upload_manager.dart';
import 'video_record_screen.dart';
import '../../utils/auth_service.dart';
import 'audio_record_screen.dart';

class DiaryScreen extends StatefulWidget {
  final String roomId;

  const DiaryScreen({super.key, required this.roomId});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();

  // Состояние
  final List<MessagePresentation> _messages = [];

  final List<SelectedMedia> _selectedMedia = [];
  List<MessageTag> _currentSelectedTags = [];

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _limit = 20;
  bool isMyRoom = false;
  String? _linkWorkshop;
  String? _linkPost;

  bool _isLoadingRoomInfo = false;
  Author? author;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final myId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myId;

    _loadRoomInfo();
    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadRoomInfo() async {
    if (_isLoadingRoomInfo) return;

    if (mounted) {
      setState(() {
        _isLoadingRoomInfo = true;
      });
    }

    try {
      final response = await getRoomInfoById(widget.roomId);

      if (!response.success) {
        return;
      }

      author = response.data['roomInfo'] as Author;
    } catch (e) {
      return;
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingRoomInfo = false;
        });
      }
    }
  }

  Future<void> _loadMessages() async {
    if (_isLoading || !_hasMore) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final response = await getMessages(
        roomId: widget.roomId,
        page: _currentPage,
        limit: _limit,
      );
      if (!response.success) {
        _errorMessage = response.message ?? "Ошибка при загрузке сообщений";
        return;
      }

      final GettingMessages gotMessages = GettingMessages.fromMap(
        response.data,
      );

      if (mounted) {
        setState(() {
          _currentPage++;
          _messages.addAll(gotMessages.messages);
          if (gotMessages.messages.length < _limit) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _errorMessage = "Ошибка в работе приложения";
        await AppInfoDialog.show(context, "Возникла непредвиденная ошибка во время работы приложения. Пожалуйста, обратитесь в поддержку.");
      }
      return;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onRefresh() {
    _hasMore = true;
    _currentPage = 0;
    _messages.clear();
    _errorMessage = null;
    _loadRoomInfo();
    _loadMessages();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMessages();
    }
  }

  void _handleClearPost() {
    if (mounted) {
      setState(() {
        _linkPost = null;
      });
    }
  }

  void _handleClearWorkshop() {
    if (mounted) {
      setState(() {
        _linkWorkshop = null;
      });
    }
  }

  Future<void> _actionMessage(
    MessageAction action,
    MessagePresentation message,
  ) async {
    switch (action) {
      case MessageAction.copy:
        if (message.message.content != null &&
            message.message.content!.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: message.message.content!));
        }
        break;

      case MessageAction.delete:
        final result = await deleteMessage(messageId: message.message.id);

        if (!result.success) {
          if (mounted) {
            await AppInfoDialog.show(context, result.message ?? "Не удалось удалить сообщение. Пожалуйста, сообщите в поддержку.");
          }
        }

        if (mounted) {
          setState(() {
            _messages.removeWhere(
              (mes) => mes.message.id == message.message.id,
            );
          });
        }
        break;
    }
  }

  void _handleCreateVoiceNote() async {
    final VoiceRecordResult? audio = (await Navigator.push<VoiceRecordResult?>(
      context,
      MaterialPageRoute(builder: (context) => const AudioRecordScreen()),
    ));

    if (audio != null && mounted) {
      final uploadProvider = context.read<UploadManager>();

      // Снимаем фокус с клавиатуры, если он был
      FocusScope.of(context).unfocus();

      uploadProvider.addMessage(
        type: MessageType.voiceNote,
        messageText: null,
        media: null,
        videoNote: null,
        audioNote: audio,
        addMessageCallback: (newMessage) {
          if (mounted) {
            setState(() {
              _messages.insert(0, newMessage);
            });
          }
        },
      );
    }
  }

  void _handleCreateVideoNote() async {
    final VideoRecordResult? video = (await Navigator.push<VideoRecordResult?>(
      context,
      MaterialPageRoute(builder: (context) => const VideoRecordScreen()),
    ));

    if (video != null && mounted) {
      final uploadProvider = context.read<UploadManager>();
      // Снимаем фокус с клавиатуры, если он был
      FocusScope.of(context).unfocus();

      uploadProvider.addMessage(
        type: MessageType.videoNote,
        messageText: null,
        media: null,
        videoNote: video,
        audioNote: null,
        addMessageCallback: (newMessage) {
          if (mounted) {
            setState(() {
              _messages.insert(0, newMessage);
            });
          }
        },
      );
    }
  }

  Future<void> _handleBindLink() async {
    final LinkAction? result = await showDialog<LinkAction>(
      context: context,
      barrierDismissible: true, // Закрыть при нажатии на пустую область
      builder: (context) => const DiaryLinkPicker(),
    );

    if (result != null) {
      // Обрабатываем выбор
      switch (result) {
        case LinkAction.linkWorkshop:
          if (mounted) {
            final destinationId = await context.push<String?>(
              '/select-folder-diary/${widget.roomId}',
            );

            if (destinationId != null) {
              setState(() {
                _linkWorkshop = destinationId;
              });
            }
          }
          break;
        case LinkAction.linkPost:
          if (mounted) {
            final postId = await context.push<String?>('/select_post_diary');

            if (postId != null) {
              setState(() {
                _linkPost = postId;
              });
            }
          }
          break;
      }
    }
  }

  Future<void> _sendStandardMessage() async {
    final uploader = context.read<UploadManager>();
    if (uploader.isUploading) return;

    final text = _messageController.text.trim();
    final media = List<SelectedMedia>.from(_selectedMedia);
    final linkWorkshop = _linkWorkshop;
    final linkPost = _linkPost;
    final selectedTags = List<MessageTag>.from(_currentSelectedTags);

    if (text.isEmpty && media.isEmpty) return;

    _messageController.clear();
    if (mounted) {
      setState(() {
        _linkWorkshop = null;
        _linkPost = null;
        _selectedMedia.clear();
        _currentSelectedTags.clear();
      });
      FocusScope.of(context).unfocus();
    }

    if (media.isNotEmpty) {
      AppInfoDialog.show(context, "Пожалуйста, во избежание ошибок не закрывайте приложение, пока сообщение публикуется.");
    }

    uploader.addMessage(
      type: MessageType.standard,
      messageText: text,
      media: media,
      selectedTags: selectedTags,
      linkWorkshop: linkWorkshop,
      linkPost: linkPost,
      addMessageCallback: (newMessage) {
        if (mounted) {
          setState(() {
            _messages.insert(0, newMessage);
          });
        }
      },
    );
  }

  Future<List<XFile>> _handlePickPhoto() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> photos;
    try {
      photos = await picker.pickMultiImage();
      return photos;
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Возникла непредвиденная ошибка. Не удалось получить фотографии. Пожалуйста, сообщите в поддержку.");
      }
      return [];
    }
  }

  Future<List<XFile>> _handlePickVideo() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> video;
    try {
      video = await picker.pickMultiVideo();
      return video;
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Возникла непредвиденная ошибка. Не удалось прикрепить видео. Пожалуйста, сообщите в поддержку.");
      }
      return [];
    }
  }

  Future<void> _handlePickTag() async {
    final result = await showModalBottomSheet<List<MessageTag>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TagPickerSheet(
        selectedTags: _currentSelectedTags,
        roomId: widget.roomId,
      ),
    );
    if (result != null) {
      if (mounted) {
        setState(() {
          _currentSelectedTags = result;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: const AppBackButton(),
          centerTitle: false,
          title: _isLoadingRoomInfo
              ? AuthorShimmerTile()
              : author == null
              ? AuthorEmptyTile(onRetry: _loadRoomInfo)
              : AuthorTile(author: author!),
          actions: [
            IconButton(
              onPressed: () =>
                  context.push('/search-messages/${widget.roomId}'),
              icon: Icon(Icons.search_rounded, size: context.ui.iconSizePanel),
              color: context.ui.iconColorPrimary,
            ),
          ],
        ),
        body: _buildBody()
      ),
    );
  }

  Widget _buildBody() {
    // СОСТОЯНИЕ ОШИБКИ (Показываем на весь экран, если загрузка не идет)
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _onRefresh,
        ),
      );
    }

    // ПЕРВОНАЧАЛЬНАЯ ЗАГРУЗКА (Экран пуст, данных еще нет, идет первый запрос)
    if (_isLoading && _messages.isEmpty) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    // ОСНОВНОЙ КОНТЕНТ (Здесь обрабатывается и пустой список, и заполненный)
    return SafeArea(
      child: Column(
        children: [
          // Область контента (Список или заглушка "Пусто")
          Expanded(
            child: _messages.isEmpty
                ? const Center(
              child: Text(
                "Тут пусто :(",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              reverse: true,
              controller: _scrollController,
              padding: const EdgeInsets.all(6),
              // Добавляем +1 к длине только если есть еще данные для пагинации
              itemCount: _messages.length + (_hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // При reverse: true этот лоадер красиво появится на самом верху списка при скролле
                if (index == _messages.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DiaRoomLoader(),
                    ),
                  );
                }

                return DiaryMessageCard(
                  message: _messages[index],
                  onLongPress: _actionMessage,
                );
              },
            ),
          ),

          // Панель ввода (Остается видимой всегда, даже если сообщений нет)
          if (isMyRoom)
            DiaryInputPanel(
              controller: _messageController,
              selectedMedia: _selectedMedia,
              onSend: _sendStandardMessage,
              onRemoveMediaAt: (index) {
                if (mounted) {
                  setState(() => _selectedMedia.removeAt(index));
                }
              },
              addMenu: _buildAddMenu(),
              linkPost: _linkPost,
              linkWorkshop: _linkWorkshop,
              onClosePost: _handleClearPost,
              onCloseWorkshop: _handleClearWorkshop,
              selectedTags: _currentSelectedTags,
              onCloseTag: (String id) {
                if (mounted) {
                  setState(() {
                    _currentSelectedTags.removeWhere((tag) => tag.id == id);
                  });
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _addMedia(String path) async {
    final type = DiaryUtils.getAttachmentType(path);
    if (type == null) {
      return;
    }

    final currentPhotos = _selectedMedia
        .where((m) => m.type == AttachmentType.photo)
        .length;
    final currentVideos = _selectedMedia
        .where((m) => m.type == AttachmentType.video)
        .length;

    if (type == AttachmentType.video && currentVideos >= limitVideosDiaryInMessage) {
      return;
    }
    if (type == AttachmentType.photo && currentPhotos >= limitPhotosDiaryInMessage) {
      return;
    }

    String? thumb;
    if (type == AttachmentType.video) {
      final fileSize = await DiaryUtils.getFileSize(path);
      if (fileSize > limitSizeVideoInMessageDiary) {
        if (mounted) {
          AppInfoDialog.show(context, "К сожалению, пока что нельзя прикрепить видео размером более ${limitSizeVideoInMessageDiary / (1024 * 1024)} мб. Они не будут прикреплены.");
        }
        return;
      }

      thumb = await DiaryUtils.generatePreview(path);

      if (thumb == null) {
        return;
      }
    }

    setState(() {
      _selectedMedia.add(
        SelectedMedia(file: File(path), thumbnail: thumb, type: type),
      );
    });
  }

  Widget _buildAddMenu() {
    return PopupMenuButton<CreatingDiaryAction>(
      tooltip: '',
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),

      icon: Icon(
        Icons.add_rounded,
        size: 34,
        color: context.ui.iconColorPrimary,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: context.ui.containerColor,
      elevation: 5,
      offset: const Offset(0, -140),
      onSelected: (action) async {
        FocusScope.of(context).unfocus();
        if (action == CreatingDiaryAction.photo) {
          List<XFile> media = await _handlePickPhoto();

          if (media.length > limitPhotosDiaryInMessage) {
            if (mounted) {
              await AppInfoDialog.show(context, "Можно прикрепить не более $limitPhotosDiaryInMessage фотографий.");
            }
          }

          final int takeCount = media.length <= limitPhotosDiaryInMessage ? media.length : limitPhotosDiaryInMessage;
          media = media.sublist(0, takeCount);

          for (int i = 0; i < media.length; i++) {
            await _addMedia(media[i].path);
          }
        }
        if (action == CreatingDiaryAction.video) {
          List<XFile> media = await _handlePickVideo();

          if (media.length > limitVideosDiaryInMessage) {
            if (mounted) {
              await AppInfoDialog.show(context, "Можно прикрепить не более $limitVideosDiaryInMessage видеороликов.");
            }
          }

          final int takeCount = media.length <= limitVideosDiaryInMessage ? media.length : limitVideosDiaryInMessage;
          media = media.sublist(0, takeCount);

          for (int i = 0; i < media.length; i++) {
            await _addMedia(media[i].path);
          }
        }
        if (action == CreatingDiaryAction.audioNote) {
          _handleCreateVoiceNote();
        }
        if (action == CreatingDiaryAction.videoNote) {
          _handleCreateVideoNote();
        }
        if (action == CreatingDiaryAction.link) {
          _handleBindLink();
        }
        if (action == CreatingDiaryAction.tag) {
          _handlePickTag();
        }
      },
      itemBuilder: (context) => CreatingDiaryAction.values
          .map(
            (action) => PopupMenuItem<CreatingDiaryAction>(
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
    );
  }
}
