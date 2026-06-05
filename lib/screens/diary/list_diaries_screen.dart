import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../components/loading_widget/error_widget.dart';
import '../../../components/loading_widget/loader_widget.dart';
import '../../../components/diary/diary_room_card.dart';
import '../../../utils/app_theme.dart';

// Фейковая или реальная модель для контракта данных (замени на свой класс респонса)
class DiaryRoomPresentation {
  final String roomId;
  final String nickname;
  final String? avatarUrl;
  final String lastMessage;
  final int unreadCount;

  DiaryRoomPresentation({
    required this.roomId,
    required this.nickname,
    this.avatarUrl,
    required this.lastMessage,
    required this.unreadCount,
  });
}

class DiaryListScreen extends StatefulWidget {
  const DiaryListScreen({super.key});

  @override
  State<DiaryListScreen> createState() => _DiaryListScreenState();
}

class _DiaryListScreenState extends State<DiaryListScreen> {
  final ScrollController _scrollController = ScrollController();

  final List<DiaryRoomPresentation> _rooms = [];
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

  Future<void> _loadRooms() async {
    if (_isLoading || !_hasMore) return;

    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      // Тут будет твой реальный запрос к API, например: await getDiaryRooms(...)
      await Future.delayed(const Duration(seconds: 1)); // Имитация сети

      // Имитируем успешный ответ бэкенда
      final List<DiaryRoomPresentation> mockFetchedRooms = [
        DiaryRoomPresentation(
          roomId: "room_1",
          nickname: "Александр Петров",
          avatarUrl: "https://10.188.66.227:9005/avatars-diaroom-1/demo/user1.jpeg", // Твой локальный MinIO IP для тестов
          lastMessage: "Слушай, я посмотрел твое последнее видео в Мастерской, это просто пушка! 🔥",
          unreadCount: 5,
        ),
        DiaryRoomPresentation(
          roomId: "room_2",
          nickname: "Елена Смирнова",
          avatarUrl: "", // Пустая строка для проверки дефолтной иконки-заглушки
          lastMessage: "Где можно найти исходники для дипломного проекта?",
          unreadCount: 12,
        ),
        DiaryRoomPresentation(
          roomId: "room_4",
          nickname: "ОченьДлинныйНикнеймПользователяКоторыйМожетСломатьВерсткуЕслиНеИспользоватьEllipsis",
          avatarUrl: null, // null для проверки полной безопасности
          lastMessage: "Тут тоже очень длинный текст сообщения, который должен аккуратно обрезаться на конце строки, чтобы интерфейс приложения DiaRoom оставался чистым и адаптивным.",
          unreadCount: 150, // Проверка трансформации в "99+"
        ),
        DiaryRoomPresentation(
          roomId: "room_5",
          nickname: "Дмитрий К.",
          avatarUrl: "",
          lastMessage: "Договорились, завтра на созвоне обсудим архитектуру.",
          unreadCount: 1,
        ),
      ];

      if (mounted) {
        setState(() {
          _currentPage++;
          _rooms.addAll(mockFetchedRooms);
          if (mockFetchedRooms.length < _limit) _hasMore = false;
        });
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

  void _onRefresh() {
    if (mounted) {
      setState(() {
        _hasMore = true;
        _currentPage = 0;
        _rooms.clear();
        _errorMessage = null;
      });
    }
    _loadRooms();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadRooms();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        title: _isLoading && _rooms.isEmpty
            ? Text(
          "Загрузка...",
          style: TextStyle(color: context.ui.fontColorPrimary, fontSize: 18),
        )
            : Text(
          "Дневники",
          style: TextStyle(
            color: context.ui.fontColorPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: _buildBody(),
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
      return const Center(
        child: Text(
          "Вы ни на кого не подписаны",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      // padding: const EdgeInsets.symmetric(vertical: 6),
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

        return DiaryRoomCard(
          nickname: room.nickname,
          avatarUrl: room.avatarUrl,
          lastMessage: room.lastMessage,
          unreadCount: room.unreadCount,
          onTap: () {
            // Переход в конкретный дневник по roomId
            context.push('/diary/${room.roomId}');
          },
        );
      },
    );
  }
}