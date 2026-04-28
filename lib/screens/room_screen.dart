import 'package:dia_room/components/bottom_menu/bottom_menu_component.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/models/auth_response.dart';
import 'package:dia_room/models/base_room.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dia_room/models/room.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:dia_room/configuration/urls.dart';
import 'package:provider/provider.dart';

import 'package:dia_room/api/room_api.dart' as api;
import '../components/room_screen/category_chip.dart';
import '../components/room_screen/room_header.dart';
import '../components/room_screen/section_action_button.dart';
import '../components/room_screen/statistic_card.dart';
import '../utils/auth_service.dart';

// RoomScreen отображает детальную информацию о конкретной комнате
class RoomScreen extends StatefulWidget {
  final String roomId;

  const RoomScreen({super.key, required this.roomId});

  @override
  State<RoomScreen> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<RoomScreen> {
  // Используем AuthResponse как тип данных для Future
  late Future<AuthResponse> _roomFuture;
  late bool isMyRoom;
  late BaseRoom room;
  String? myRoomId;
  bool _isBioVisible = false;

  @override
  void initState() {
    super.initState();

    final auth = context.read<AuthProvider>();
    myRoomId = auth.roomId;
    isMyRoom = (myRoomId == widget.roomId);

    _roomFuture = api.getRoomByRoomId(widget.roomId);
  }

  Future<void> _onRefresh() async {
    setState(() {
      _roomFuture = api.getRoomByRoomId(widget.roomId);
    });
    await _roomFuture;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthResponse>(
      future: _roomFuture,
      builder: (context, snapshot) {
        // СОСТОЯНИЕ: ЗАГРУЗКА
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF810202)),
            ),
          );
        }

        // СОСТОЯНИЕ: ОШИБКА ИЛИ ПУСТО
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(), // Чтобы можно было вернуться назад
            body: const Center(
              child: Text("Не удалось загрузить данные комнаты"),
            ),
          );
        }

        final response = snapshot.data!;

        // 3. Сервер вернул ошибку (success: false)
        if (!response.success) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(response.message ?? "Комната не найдена")),
          );
        }

        // 4. Всё хорошо, пробуем собрать модель
        try {
          room = BaseRoom.fromMap(response.data!);
        } catch (e) {
          print("Ошибка парсинга: $e");
          return const Scaffold(
            body: Center(child: Text("Ошибка обработки данных")),
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
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  size: context.ui.iconSizePanel,
                ),
                color: context.ui.fontColorPrimary,
              ),
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
                        roomName: room.roomName,
                        avatarUrl: room.avatarUrl,
                        backgroundUrl: room.backgroundUrl,
                      ),
                      // Основной контент под шторкой
                      Expanded(
                        child: RefreshIndicator(
                          color: const Color(0xFF810202),
                          // Твой фирменный цвет DiaRoom
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: context.ui.containerColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
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
                                          // общие отступы внутри карточки
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SingleChildScrollView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 4,
                                                      horizontal: 4,
                                                    ),
                                                child: Row(
                                                  children: room.listCategory
                                                      .map((category) {
                                                        return CategoryChip(
                                                          slug: category.slug,
                                                          name: category.name,
                                                        );
                                                      })
                                                      .toList(),
                                                ),
                                              ),

                                              if (room.listCategory.isNotEmpty)
                                                const SizedBox(height: 10),

                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                    ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    final idToCopy = room
                                                        .uniqueRoomId; // без символа @

                                                    await Clipboard.setData(
                                                      ClipboardData(
                                                        text: idToCopy,
                                                      ),
                                                    );
                                                  },
                                                  child: Text(
                                                    '@${room.uniqueRoomId}',
                                                    style: TextStyle(
                                                      color: context
                                                          .ui
                                                          .fontColorPrimary,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              const SizedBox(height: 6),

                                              // Кнопка "Показать описание" по центру
                                              if (room.bio.isNotEmpty)
                                                Center(
                                                  child: InkWell(
                                                    onTap: () => setState(
                                                      () => _isBioVisible =
                                                          !_isBioVisible,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
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

                                              // const SizedBox(height: 12),

                                              // Само описание (выровнено слева)
                                              if (_isBioVisible &&
                                                  room.bio.isNotEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        left: 4,
                                                        right: 4,
                                                      ),
                                                  child: Text(
                                                    room.bio,
                                                    textAlign: TextAlign.left,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      height: 1.5,
                                                      fontStyle:
                                                          FontStyle.italic,
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
                                          // Виджет Подписчики
                                          Expanded( // Expanded теперь ПРЯМОЙ потомок Row
                                            child: StatCard(
                                              value: room.countFollowers.toString(),
                                              label: 'подписчики',
                                              onTap: () => context.push('/followers/${widget.roomId}'),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded( // И здесь тоже
                                            child: StatCard(
                                              value: room.countFollowing.toString(),
                                              label: 'подписки',
                                              onTap: () => context.push('/following/${widget.roomId}'),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      RoomActionButton(
                                        title: 'Дневник',
                                        onPressed: () {},
                                      ),
                                      const SizedBox(height: 10),
                                      RoomActionButton(
                                        title: 'Витрина',
                                        onPressed: () => context.push(
                                          '/personalRoomPosts/${widget.roomId}',
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      RoomActionButton(
                                        title: 'Мастерская',
                                        onPressed: () {},
                                      ),
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
      }, // Конец builder
    );
  }
}
