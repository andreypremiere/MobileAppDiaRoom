import 'package:dia_room/components/general/app_back_button.dart';
import 'package:dia_room/models/enums/diary/message_type.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/loading_widget/error_widget.dart';
import '../../../components/loading_widget/loader_widget.dart';
import '../../../components/diary/diary_room_card.dart';
import '../../../utils/app_theme.dart';
import '../../api/auth_response.dart';
import '../../api/diary_api.dart';
import '../../contracts/diary/response/diaries.dart';

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<DiaryCard> _rooms = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final int _limit = 20;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (mounted) {
      setState(() {
        _hasMore = true;
        _currentPage = 0;
        _rooms.clear();
        _errorMessage = null;
      });
    }
    await _loadRooms();
  }

  Future<void> _loadRooms() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final AuthResponse response = await getDiaries(
        page: _currentPage,
        limit: _limit,
      );

      if (response.success && response.data != null) {
        final diariesData = Diaries.fromMap(response.data as Map<String, dynamic>);
        final List<DiaryCard> fetchedRooms = diariesData.diaries;

        if (mounted) {
          setState(() {
            _currentPage++;
            _rooms.addAll(fetchedRooms);

            if (fetchedRooms.length < _limit) {
              _hasMore = false;
            }
          });
        }
      } else {
        throw Exception(response.message ?? "Не удалось загрузить данные");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Ошибка при загрузке дневников";
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (_hasMore) _loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: const AppBackButton(),
        title: _isLoading && _rooms.isEmpty
            ? const Text("Загрузка...")
            : const Text("Дневники"),
        centerTitle: false,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_errorMessage != null && !_isLoading) {
      return Center(
        child: DiaRoomErrorView(
          errorMessage: _errorMessage!,
          onRefresh: _onRefresh,
        ),
      );
    }

    if (_isLoading && _rooms.isEmpty) {
      return const Center(
        child: DiaRoomLoader(),
      );
    }

    if (_rooms.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: const Center(
              child: Text(
                "Вы ни на кого не подписаны",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: _rooms.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _rooms.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: DiaRoomLoader(),
            ),
          );
        }

        final room = _rooms[index];

        String displayMessage = room.message?.content ?? "";

        if (displayMessage.isEmpty) {
          if (room.message?.msgType == MessageType.voiceNote) {
            displayMessage = "Аудиосообщение";
          } else if (room.message?.attachedObjectPostV2Id != null ||
              room.message?.attachedObjectPostId != null ||
              room.message?.attachedObjectWorkshopId != null
          ) {
            displayMessage = "Ссылка";
          } else if (room.message != null) {
            displayMessage = "Медиавложения";
          }
        }

        return DiaryRoomCard(
          nickname: room.author.roomName,
          avatarUrl: room.author.avatar,
          lastMessage: displayMessage,
          lastMessageAt: room.lastMessageAt,
          unreadCount: room.unreadCount,
          onTap: () async {
            await updateState(authorId: room.author.roomId);

            if (context.mounted) {
              setState(() {
                _rooms[index] = room.copyWith(unreadCount: 0);
              });

              context.push('/diary/${room.author.roomId}');
            }
          },
        );
      },
    );
  }
}