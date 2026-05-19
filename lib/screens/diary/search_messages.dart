import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/api/diary_api.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/search_method.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/diary/message_card.dart';
import '../../components/general/app_back_button.dart';
import '../../models/enums/diary/message_action.dart';

class SearchMessagesScreen extends StatefulWidget {
  final String roomId;
  final String? text;
  final SearchMethod? method;

  const SearchMessagesScreen({
    super.key,
    required this.roomId,
    this.text,
    this.method,
  });

  @override
  State<SearchMessagesScreen> createState() => _SearchMessagesScreenState();
}

class _SearchMessagesScreenState extends State<SearchMessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<MessagePresentation> _messages = [];
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  SearchMethod _currentMethod = SearchMethod.byMessage;

  @override
  void initState() {
    super.initState();
    print('id комнаты: ${widget.roomId}');
    _scrollController.addListener(_onScroll);

    if (widget.text != null) {
      _searchController.text = widget.text!;
    }

    if (widget.method != null) {
      _currentMethod = widget.method!;
    }

    if (widget.text != null && widget.text!.trim().isNotEmpty) {
      _fetchMessages();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _fetchMessages();
      }
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
          print("Не удалось удалить сообщение");
          return;
        }

        setState(() {
          _messages.removeWhere((mes) => mes.message.id == message.message.id);
        });
        break;
    }
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);

    try {
      if (_searchController.text.trim().isEmpty) {
        return;
      }

      AuthResponse response;
      switch (_currentMethod) {
        case SearchMethod.byTag:
          response = await searchMessages(
            roomId: widget.roomId,
            page: _currentPage,
            limit: _limit,
            tagText: _searchController.text.trim(),
          );
          break;
        case SearchMethod.byMessage:
          response = await searchMessages(
            roomId: widget.roomId,
            page: _currentPage,
            limit: _limit,
            messageText: _searchController.text.trim(),
          );
      }

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

  void _clearText() {
    setState(() {
      _searchController.clear();
      _messages.clear();
      _currentPage = 0;
    });
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _searchMessages() {
    _currentPage = 0;
    _messages.clear();
    _fetchMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        centerTitle: false,
        leading: const AppBackButton(),
        titleSpacing: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                // Ограничиваем высоту контейнера
                height: 46, child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Поиск в комнате...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 10),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearText,
                  ),
                ),),
              ),
            ),
            IconButton(
              onPressed: _searchMessages,
              icon: Icon(
                Icons.search,
                size: context.ui.iconSizePanel,
                color: context.ui.iconColorPrimary,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: _searchController.text.trim().isEmpty
            ? 1
            : (_messages.length + (_isLoading ? 1 : 0)),
        itemBuilder: (context, index) {
          if (_searchController.text.trim().isEmpty) {
            return const Center(child: Text("Введите значение"));
          } else {
            if (index == _messages.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return DiaryMessageCard(
              message: _messages[index],
              onLongPress: _actionMessage,
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}
