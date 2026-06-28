import 'package:dia_room/api/auth_response.dart';
import 'package:dia_room/api/diary_api.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/components/loading_widget/error_widget.dart';
import 'package:dia_room/contracts/diary/response/getting_messages.dart';
import 'package:dia_room/models/enums/diary/search_method.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../components/diary/message_card.dart';
import '../../components/general/app_back_button.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../models/enums/diary/message_action.dart';
import '../../utils/auth_service.dart';

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

  final List<MessagePresentation> _messages = [];
  int _currentPage = 0;
  final int _limit = 20;
  bool _isLoading = false;
  bool _hasMore = true;
  SearchMethod _currentMethod = SearchMethod.byMessage;
  String? _errorMessage;
  bool isMyRoom = false;

  @override
  void initState() {
    super.initState();

    final myId = context.read<AuthProvider>().roomId;
    isMyRoom = widget.roomId == myId;

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
          if (mounted) {
            await AppInfoDialog.show(context, result.message ?? "Не удалось удалить сообщение. Пожалуйста, обратитесь в поддержку.");
          }
          return;
        }
        if (mounted) {
          setState(() {
            _messages.removeWhere((mes) => mes.message.id == message.message.id);
          });
        }
        break;
    }
  }

  void onTapMethod(SearchMethod method) {
    if (mounted) {
      setState(() {
        _currentMethod = method;
      });
    } else {
      return;
    }
    _searchMessages();
  }

  Widget _buttonMethod(SearchMethod method) {
    return ElevatedButton(
      onPressed: () {
        onTapMethod(method);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: method == _currentMethod
            ? context.ui.primaryColor
            : context.ui.containerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),

          side: method == _currentMethod
              ? BorderSide.none
              : BorderSide(color: context.ui.primaryColor, width: 2),
        ),

        elevation: 0,
      ),
      child: Text(
        method.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: method != _currentMethod
              ? context.ui.primaryColor
              : context.ui.containerColor,
        ),
      ),
    );
  }

  Widget _panelButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: 36,
          minHeight: 0,
        ),
        child: ListView.separated(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: SearchMethod.values.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            return _buttonMethod(SearchMethod.values[index]);
          },
        ),
      ),
    );
  }

  Future<void> _fetchMessages() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

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

      print('Запрос $response');

      if (!response.success) {
        print("Запрос не выполнился");
        _errorMessage = response.message ?? "Не удалось выполнить запрос.";
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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearText() {
    if (mounted) {
      setState(() {
        _searchController.clear();
        _messages.clear();
        _errorMessage = null;
        _currentPage = 0;
        _hasMore = true;
      });
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  void _searchMessages() {
    _errorMessage =  null;
    _hasMore = true;
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
                height: 46,
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "Поиск в комнате...",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 10),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearText,
                    ),
                  ),
                ),
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
      body: Column(
        children: [
          _panelButtons(),
          buildBody()
        ],
      ),
    );
  }

  Widget buildBody() {
    if (_errorMessage != null && !_isLoading) {
      return Expanded(
        child: Center(
          child: DiaRoomErrorView(
            errorMessage: _errorMessage!,
            onRefresh: _searchMessages,
          ),
        ),
      );
    }

    if (_isLoading && _messages.isEmpty) {
      return const Expanded(
        child: Center(
          child: DiaRoomLoader(),
        ),
      );
    }

    if (_searchController.text.trim().isEmpty) {
      return const Expanded(
        child: SizedBox.shrink(),
      );
    }

    if (!_isLoading && _messages.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            "Список пуст",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length + (_isLoading ? 1 : 0),
        itemBuilder: (context, index) {
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
            onLongPress: isMyRoom ? _actionMessage : null,
          );
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
