import 'package:dia_room/components/general/app_back_button.dart';
import 'package:dia_room/models/room/base_room.dart';
import 'package:dia_room/screens/room/rooms_list_screen.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../api/account_api.dart';
import '../../components/loading_widget/error_widget.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../components/room_screen/category_chip.dart';
import '../../components/room_screen/diary_button_widget.dart';
import '../../components/room_screen/room_header.dart';
import '../../components/room_screen/statistic_card.dart';
import '../../utils/auth_service.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<RoomScreen> {
  late bool isMyRoom;
  BaseRoom? room;
  String? myRoomId;
  bool _isBioVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    myRoomId = auth.roomId;
    isMyRoom = (myRoomId == widget.roomId);

    _loadRoomData();
  }

  Future<void> _loadRoomData() async {
    if (_isLoading) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final response = await getRoomByRoomId(widget.roomId);

      if (mounted) {
        if (!response.success) {
          setState(() {
            _errorMessage = response.message ?? "Ошибка при запросе комнаты.";
          });
          return;
        }

        setState(() {
          room = BaseRoom.fromMap(response.data!);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              "Ошибка во время работы приложения. Пожалуйста, сообщите в поддержку.";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    _loadRoomData();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: const AppBackButton(),
          centerTitle: false,
          title: const Text(
            "Ошибка",
          ),
        ),
        body: Center(
          child: DiaRoomErrorView(
            errorMessage: _errorMessage!,
            onRefresh: _onRefresh,
          ),
        ),
      );
    }

    if (_isLoading && room == null) {
      return const Scaffold(
        body: Center(
          child: DiaRoomLoader(),
        ),
      );
    }

    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: const AppBackButton(),
        ),
        body: const Center(child: Text("Данные комнаты отсутствуют")),
      );
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          forceMaterialTransparency: true,
          leading: AppBackButton(),
        ),
        body: SafeArea(
          top: false,
          child: Stack(
            children: [
              Column(
                children: [
                  RoomHeader(
                    isMyRoom: isMyRoom,
                    roomId: widget.roomId,
                    roomName: room!.roomName,
                    avatarUrl: room!.avatarUrl,
                    backgroundUrl: room!.backgroundUrl,
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      color: context.ui.primaryColor,
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: context.ui.containerColor,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                              horizontal: 4,
                                            ),
                                            child: Row(
                                              children: room!.listCategory.map((
                                                category,
                                              ) {
                                                return CategoryChip(
                                                  slug: category.slug,
                                                  name: category.label,
                                                );
                                              }).toList(),
                                            ),
                                          ),

                                          if (room!.listCategory.isNotEmpty)
                                            const SizedBox(height: 10),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final idToCopy = room!
                                                    .uniqueRoomId;

                                                await Clipboard.setData(
                                                  ClipboardData(text: idToCopy),
                                                );
                                              },
                                              child: Text(
                                                '@${room!.uniqueRoomId}',
                                                style: TextStyle(
                                                  color: context
                                                      .ui
                                                      .fontColorPrimary,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          if (room!.bio.isNotEmpty)
                                            Center(
                                              child: InkWell(
                                                onTap: () {
                                                  if (mounted) {
                                                    setState(
                                                      () => _isBioVisible =
                                                          !_isBioVisible,
                                                    );
                                                  }
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16,
                                                      ),
                                                  child: Text(
                                                    _isBioVisible
                                                        ? "Скрыть описание"
                                                        : "Показать описание",
                                                    style: TextStyle(
                                                      color: context
                                                          .ui
                                                          .fontColorHint,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          if (_isBioVisible &&
                                              room!.bio.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                                right: 4,
                                              ),
                                              child: Text(
                                                room!.bio,
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  height: 1.5,
                                                  fontStyle: FontStyle.italic,
                                                  color: context
                                                      .ui
                                                      .fontColorPrimary,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: StatCard(
                                          value: room!.countFollowers
                                              .toString(),
                                          label: 'подписчики',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RoomListScreen(
                                                    title: 'Подписчики',
                                                    loadAction: (page, limit) =>
                                                        requestGetFollowers(
                                                          roomId: widget.roomId,
                                                          page: page,
                                                          limit: limit,
                                                        ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: StatCard(
                                          value: room!.countFollowing
                                              .toString(),
                                          label: 'подписки',
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  RoomListScreen(
                                                    title: 'Подписки',
                                                    loadAction: (page, limit) =>
                                                        requestGetFollowing(
                                                          roomId: widget.roomId,
                                                          page: page,
                                                          limit: limit,
                                                        ),
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DiaryButtonWidget(roomId: widget.roomId),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ShowcaseButtonWidget(roomId: widget.roomId),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  WorkshopButtonWidget(roomId: widget.roomId,),
                                  const SizedBox(height: 12),
                                  ArticleButtonWidget(roomId: widget.roomId),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
