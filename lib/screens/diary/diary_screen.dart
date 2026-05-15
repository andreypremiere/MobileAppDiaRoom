import 'dart:io';

import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../api/account_api.dart';
import '../../api/auth_response.dart';
import '../../api/diary_api.dart';
import '../../components/diary/diary_link_picker.dart';
import '../../components/diary/input_panel.dart';
import '../../components/diary/message_card.dart';
import '../../components/general/app_avatar.dart';
import '../../components/general/app_back_button.dart';
import '../../models/diary/selected_media.dart';
import '../../models/enums/diary/attachment_type.dart';
import '../../models/enums/diary/creating_actions.dart';
import '../../models/enums/diary/link_objects.dart';
import '../../models/enums/diary/message_type.dart';
import '../../models/post_view/author.dart';
import '../../services/diary/diary_utils.dart';
import '../../services/diary/upload_manager.dart';
import '../../services/diary/video_record_screen.dart';
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
  List<MessagePresentation> _messages = [];

  List<SelectedMedia> _selectedMedia = [];
  final int _maxPhotos = 5;
  final int _maxVideos = 2;

  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _limit = 20;
  bool isMyRoom = false;
  String? _linkWorkshop;
  String? _linkPost;

  late Future<AuthResponse> _roomInfoFuture;

  @override
  void initState() {
    super.initState();

    final myId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myId;
    print('Пользователь авторизован? $myId');

    _roomInfoFuture = getRoomInfoById(widget.roomId);

    _loadMessages();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final response = await getMessages(
        roomId: widget.roomId,
        page: _currentPage,
        limit: _limit,
      );
      if (!response.success) {
        print('Не удалось загрузить сообщения');
        return;
      }

      print(response.data);
      final GettingMessages gotMessages = GettingMessages.fromMap(
        response.data,
      );

      setState(() {
        _currentPage++;
        _messages.addAll(gotMessages.messages);
        // Если пришло меньше чем лимит, значит данных больше нет
        if (gotMessages.messages.length < _limit) _hasMore = false;
      });
    } catch (e) {
      print('Возникла непредвиденная ошибка в парсинге $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onScroll() {
    // Если долистали до конца (осталось 200 пикселей до низа)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMessages();
    }
  }

  void _handleClearPost() {
    setState(() {
      _linkPost = null;
    });
  }

  void _handleClearWorkshop() {
    setState(() {
      _linkWorkshop = null;
    });
  }

  void _handleCreateVoiceNote() async {
    final VoiceRecordResult? audio = (await Navigator.push<VoiceRecordResult?>(
      context,
      MaterialPageRoute(builder: (context) => const AudioRecordScreen()),
    ));

    print('Путь к аудиосообщению: $audio');

    if (audio != null && mounted) {
      final uploadProvider = context.read<UploadManager>();
      print("Путь: ${audio.path}");
      print("Длительность: ${audio.duration.inSeconds} сек");

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
      print(video.path);
      print(video.duration.inMilliseconds);
      print(video.sizeInBytes);

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
          print("Выбрана мастерская");
          final destinationId = await context.push<String?>(
            '/select-folder-diary/${widget.roomId}',
          );

          if (destinationId != null) {
            print("Выбранная папка назвачения: $destinationId");
            setState(() {
              _linkWorkshop = destinationId;
            });
          }
          break;
        case LinkAction.linkPost:
          print("Выбрана публикация");
          final postId = await context.push<String?>(
            '/select_post_diary',
          );

          if (postId != null) {
            print("Выбранный пост: $postId");
            setState(() {
              _linkPost = postId;
            });
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

    if (text.isEmpty && media.isEmpty) return;

    _messageController.clear();
    setState(() {
      _linkWorkshop = null;
      _linkPost = null;
      _selectedMedia.clear();
    });
    FocusScope.of(context).unfocus();

    uploader.addMessage(
      type: MessageType.standard,
      messageText: text,
      media: media,
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
    List<XFile> photo;
    try {
      photo = await picker.pickMultiImage(limit: 5);
      return photo;
    } catch (e) {
      print("Ошибка при выборе нескольких изображений: $e");
      return [];
    }
  }

  Future<List<XFile>> _handlePickVideo() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> video;
    try {
      video = await picker.pickMultiVideo(limit: 2);
      return video;
    } catch (e) {
      print("Ошибка при выборе нескольких изображений: $e");
      return [];
    }
  }

  Widget _buildSkeletonItem({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(20),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmerTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Скелет для аватара
        _buildSkeletonItem(width: 36, height: 36, radius: 18),
        const SizedBox(width: 10),
        // Скелет для имени
        _buildSkeletonItem(width: 100, height: 20, radius: 4),
      ],
    );
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
          title: FutureBuilder<AuthResponse>(
            future: _roomInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildShimmerTitle();
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.success) {
                return const SizedBox.shrink();
              }

              // Данные загружены
              final roomInfo = snapshot.data!.data!['roomInfo'] as Author;

              return InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppAvatar(imageUrl: roomInfo.avatar, radius: 18),
                      const SizedBox(width: 10),
                      Text(
                        roomInfo.roomName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: context.ui.fontColorPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  padding: const EdgeInsets.all(6),
                  itemCount: _messages.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    print('Текущая длина списка месседж: ${_messages.length}');
                    if (index == _messages.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    return DiaryMessageCard(message: _messages[index]);
                  },
                ),
              ),
              isMyRoom
                  ? DiaryInputPanel(
                      controller: _messageController,
                      selectedMedia: _selectedMedia,
                      onSend: _sendStandardMessage,
                      onRemoveMediaAt: (index) =>
                          setState(() => _selectedMedia.removeAt(index)),
                      addMenu: _buildAddMenu(),
                      linkPost: _linkPost,
                      linkWorkshop: _linkWorkshop,
                      onClosePost: _handleClearPost,
                      onCloseWorkshop: _handleClearWorkshop,
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  void _showLimitWarning(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Color(0xFF262626))),
        backgroundColor: Color(0xFFE5E5E5),
        behavior: SnackBarBehavior.floating,
        // Делает его "парящим" над нижней панелью
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'ОК',
          textColor: Color(0xFF262626),
          onPressed: () {
            // Действие при нажатии на кнопку в SnackBar
          },
        ),
      ),
    );
  }

  Future<void> _addMedia(String path) async {
    final type = DiaryUtils.getAttachmentType(path);
    if (type == null) {
      print("Не поддерживаемый тип файла");
      // Snackbar
      return;
    }

    final currentPhotos = _selectedMedia
        .where((m) => m.type == AttachmentType.photo)
        .length;
    final currentVideos = _selectedMedia
        .where((m) => m.type == AttachmentType.video)
        .length;

    if (type == AttachmentType.video && currentVideos >= _maxVideos) {
      _showLimitWarning("Можно прикрепить только 2 видео");
      return;
    }
    if (type == AttachmentType.photo && currentPhotos >= _maxPhotos) {
      _showLimitWarning("Можно прикрепить только 5 фото");
      return;
    }

    String? thumb;
    if (type == AttachmentType.video) {
      thumb = await DiaryUtils.generatePreview(path);

      if (thumb == null) {
        // SnackBar: "Не удалось сгенерировать превью"
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
          final media = await _handlePickPhoto();
          for (int i = 0; i < media.length; i++) {
            await _addMedia(media[i].path);
          }
        }
        if (action == CreatingDiaryAction.video) {
          final media = await _handlePickVideo();
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
