import 'package:dia_room/components/bottom_menu_component.dart';
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

    // Просто присваиваем вызов функции переменной.
    // НЕ пишем await здесь!
    _roomFuture = api.getRoomByRoomId(widget.roomId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthResponse>(
      future: _roomFuture,
      builder: (context, snapshot) {
        // СОСТОЯНИЕ: ЗАГРУЗКА
        if (snapshot.connectionState == ConnectionState.waiting) {
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
          return const Scaffold(body: Center(child: Text("Ошибка обработки данных")));
        }

        return GestureDetector(
          // Убираем фокус с элементов ввода при нажатии на фон
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);
            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: Scaffold(
            // Позволяет телу заходить под AppBar
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              forceMaterialTransparency: true,
              // backgroundColor: const Color(0xFFFFA6A6).withAlpha(0),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(Icons.arrow_back_rounded,
                    size: context.ui.iconSizePanel),
                color: context.ui.fontColorPrimary,
              ),
              // actions: [
              //   // Здесь исправить на провайдера
              //   if (isMyRoom)
              //     IconButton(
              //       onPressed: () => {
              //         //   Здесь делать редирект на страницу редактирования комнаты
              //       },
              //       icon: SvgPicture.asset(
              //         'assets/icons/edit.svg',
              //         width: 28,
              //         height: 28,
              //         colorFilter: const ColorFilter.mode(
              //           Color(0x80000000), // Цвет, в который хотим покрасить
              //           BlendMode
              //               .srcIn, // Режим наложения (srcIn — закрасить иконку целиком)
              //         ),
              //       ),
              //     ),
              //   const SizedBox(width: 8),
              // ],
            ),
            body: SafeArea(
              top: false,
              child: Stack(
              children: [
                Column(
                  children: [
                    // Верхняя часть: Обложка профиля (Шторка)
                    AspectRatio(
                      aspectRatio: 4 / 3, // Просто задаем пропорцию
                      child: Container(
                        width: double.infinity,
                        // height: 220,
                        decoration: BoxDecoration(
                          image: (room.backgroundUrl.isNotEmpty)
                              ? DecorationImage(
                            image: NetworkImage(room.backgroundUrl,
                              ), // Или NetworkImage
                            fit: BoxFit.cover,
                          )
                              : null,
                          // color: Color(0xFFB7B7B7), // Тот самый однотонный цвет
                        ),
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                          ),
                          child: Stack(
                            children: [
                              // Название комнаты поверх обложки с тенью для читаемости
                              Positioned(
                                bottom: 15,
                                left: 15,
                                child: Text(
                                  room.roomName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'SNPro',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 24,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 15.0,
                                        color: Colors.black54,
                                        offset: Offset(1.0, 1.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Аватар и блок спонсора
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      CircleAvatar(
                                        radius: 40,
                                        backgroundColor: Color(0xFF939393),
                                        backgroundImage:
                                            (room.avatarUrl.isNotEmpty)
                                            ? NetworkImage(
                                                  room.avatarUrl,
                                              ) : null
                                      ),
                                      // Container(
                                      //   height: 60,
                                      //   width: 120,
                                      //   decoration: BoxDecoration(
                                      //     borderRadius: BorderRadius.circular(
                                      //       10,
                                      //     ),
                                      //     color: Colors.white.withAlpha(50),
                                      //   ),
                                      //   child: const Center(
                                      //     child: Text("Спонсор"),
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Основной контент под шторкой
                    Expanded(
                      child: SingleChildScrollView(
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
                                      color: const Color(0xFFE1DFDA),
                                      borderRadius: BorderRadius.circular(16),
                                      // чуть округлил для современного вида
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
                                          // 1. Категории как чипсы в горизонтальном скролле
                                          SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: room.listCategory.map((
                                                category,
                                              ) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFE1DFDA),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withAlpha(30),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/icons/${category.slug}.svg',
                                                        width: 16,
                                                        height: 16,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        category.name,
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontFamily: 'SNPro',
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),

                                          if (room.listCategory.isNotEmpty)
                                            const SizedBox(height: 10),

                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8,
                                            ),
                                            child: GestureDetector(
                                              onTap: () async {
                                                final idToCopy = room.uniqueRoomId; // без символа @

                                                await Clipboard.setData(
                                                  ClipboardData(text: idToCopy),
                                                );

                                                // // Уведомление пользователю
                                                // if (mounted) {
                                                //   ScaffoldMessenger.of(context).showSnackBar(
                                                //     SnackBar(
                                                //       content: Text('ID скопирован: @$idToCopy'),
                                                //       duration: const Duration(seconds: 2),
                                                //       behavior: SnackBarBehavior.floating,
                                                //       backgroundColor: const Color(0xFF810202),
                                                //     ),
                                                //   );
                                                // }
                                              },
                                              child: Text(
                                                '@${room.uniqueRoomId}',
                                                style: const TextStyle(
                                                  color: Color(0xFF3D3D3D),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: 'SNPro',
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 6),

                                          // 3. Кнопка "Показать описание" по центру
                                          if (room.bio != null &&
                                              room.bio!.isNotEmpty)
                                            Center(
                                              child: InkWell(
                                                onTap: () => setState(
                                                  () => _isBioVisible =
                                                      !_isBioVisible,
                                                ),
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
                                                    style: const TextStyle(
                                                      color: Color(0xFF797979),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 15,
                                                      fontFamily: 'SNPro',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                          // const SizedBox(height: 12),

                                          // 4. Само описание (выровнено слева)
                                          if (_isBioVisible &&
                                              room.bio != null &&
                                              room.bio!.isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                                right: 4,
                                              ),
                                              child: Text(
                                                room.bio!,
                                                textAlign: TextAlign.left,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  height: 1.5,
                                                  fontStyle: FontStyle.italic,
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
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE1DFDA),
                                            // Твой цвет фона (мастерской/витрины)
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  25,
                                                ), // Очень легкая тень
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '524',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  fontFamily: 'SNPro',
                                                ),
                                              ),
                                              const Text(
                                                'подписчики',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // Отступ между карточками
                                      // Виджет Подписки
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE1DFDA),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(
                                                  25,
                                                ),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '42',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  fontFamily: 'SNPro',
                                                ),
                                              ),
                                              const Text(
                                                'подписки',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Кнопка "Дневник"
                                  Container(
                                    decoration: BoxDecoration(
                                      // borderRadius: BorderRadius.circular(14),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 8,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        minimumSize: const Size(
                                          double.infinity,
                                          60,
                                        ),
                                        alignment: Alignment.centerLeft,
                                        backgroundColor: const Color(
                                          0xFFE1DFDA,
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ), // Увеличил для наглядности
                                          // side: const BorderSide(color: Colors.black12, width: 1),
                                        ),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        'Дневник',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 26,
                                          fontFamily: 'Caveat',
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10),

                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE1DFDA),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(25),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                          offset: const Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Заголовок + кнопка добавления
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Витрина',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 26,
                                                  fontFamily: 'Caveat',
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  context.push(
                                                    '/newPublicPost',
                                                  );
                                                },
                                                icon: SvgPicture.asset(
                                                  'assets/icons/plus.svg',
                                                  width: 28,
                                                  height: 28,
                                                ),
                                              ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          // Кнопка "Смотреть все" — теперь коричневая, как "Дневник"
                                          SizedBox(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF810202,
                                                ),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  context.push('/roomPosts'),
                                              child: const Text(
                                                "Смотреть все",
                                                style: TextStyle(
                                                  fontFamily: 'SNPro',
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Секция "Мастерская" с внешней кастомной тенью
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(25),
                                      blurRadius: 8,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(
                                      double.infinity,
                                      60,
                                    ),
                                    alignment: Alignment.centerLeft,
                                    backgroundColor: const Color(0xFFE1DFDA),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        14,
                                      ), // Увеличил для наглядности
                                      // side: const BorderSide(color: Colors.black12, width: 1),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text(
                                    'Мастерская',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 26,
                                      fontFamily: 'Caveat',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),),
          ),
        );
      }, // Конец builder
    );
  }
}
