import 'package:dia_room/components/bottom_menu_component.dart';
import 'package:flutter/material.dart';
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
  late Future<Map<String, dynamic>?> _roomFuture;
  late String? currentRoomId;
  bool _isBioVisible = false; // Состояние, показано ли bio или нет

  @override
  void initState() {
    super.initState();
    // Инициализируем запрос при старте.
    // context.read можно использовать в initState, если не слушать изменения.
    currentRoomId = context.read<AuthProvider>().user?.roomId;
    final token = context.read<AuthProvider>().user?.token ?? "";
    _roomFuture = api.getRoomByRoomId(widget.roomId, token);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
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

        // СОСТОЯНИЕ: ДАННЫЕ ЕСТЬ
        // Превращаем Map в объект Room
        final Room? room = Room.fromJson(snapshot.data!);

        if (room == null)
          return Scaffold(body: Text('Ошибка преобразования в Room'));

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
              backgroundColor: const Color(0xFFFFA6A6).withAlpha(0),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset(
                  'assets/icons/button_back.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              actions: [
                if (widget.roomId == currentRoomId)
                  IconButton(
                    onPressed: () => {
                      //   Здесь делать редирект на страницу редактирования комнаты
                    },
                    icon: SvgPicture.asset(
                      'assets/icons/edit.svg',
                      width: 28,
                      height: 28,
                      colorFilter: const ColorFilter.mode(
                        Color(0x80000000), // Цвет, в который хотим покрасить
                        BlendMode
                            .srcIn, // Режим наложения (srcIn — закрасить иконку целиком)
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
            body: Stack(
              children: [
                Column(
                  children: [
                    // Верхняя часть: Обложка профиля (Шторка)
                    Container(
                      width: double.infinity,
                      height: 220,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/background_profile.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        color: Color(0xFFCB6C6C),
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
                                      backgroundImage:
                                          (room.avatarUrl != null &&
                                              room.avatarUrl!.isNotEmpty)
                                          ? NetworkImage(
                                              createFullPathAvatar(
                                                objectStoragePath,
                                                room.avatarUrl!,
                                              ),
                                            )
                                          : NetworkImage(
                                              createFullPathAvatar(
                                                objectStoragePath,
                                                defaultAvatarPath,
                                              ),
                                            ),
                                    ),
                                    Container(
                                      height: 60,
                                      width: 120,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.blueGrey.withAlpha(80),
                                      ),
                                      child: const Center(
                                        child: Text("Спонсор"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                  // Секция категорий (теги)
                                  Wrap(
                                    spacing: 8,
                                    children: room.categories.map((category) {
                                      return Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/${category.slug}.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'SNPro',
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 5),
                                  // Секция био с переключателем "Показать/Скрыть"
                                  if (room.bio != null &&
                                      room.bio!.isNotEmpty) ...[
                                    if (_isBioVisible)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          room.bio!,
                                          style: const TextStyle(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 14,
                                            // fontFamily: 'Caveat',
                                          ),
                                        ),
                                      ),
                                    InkWell(
                                      onTap: () => setState(
                                        () => _isBioVisible = !_isBioVisible,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 4,
                                        ),
                                        child: Text(
                                          _isBioVisible
                                              ? "Скрыть описание"
                                              : "Показать описание",
                                          style: const TextStyle(
                                            color: Colors.black26,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'SNPro',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 10),
                                  // Кнопка "Дневник"
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize: const Size(
                                        double.infinity,
                                        60,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor: const Color(0xFF810202),
                                    ),
                                    onPressed: () {},
                                    child: const Text(
                                      "Дневник",
                                      style: TextStyle(
                                        fontFamily: "Caveat",
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Секция "Витрина" с кнопкой перехода к постам
                            Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 14,
                              ),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE1DFDA),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(30),
                                    blurRadius: 14,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                          context.push('/newPublicPost');
                                        },
                                        icon: SvgPicture.asset(
                                          'assets/icons/plus.svg',
                                          width: 28,
                                          height: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.center,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          context.push('/roomPosts'),
                                      style: ElevatedButton.styleFrom(
                                        elevation: 1,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 10,
                                        ),
                                        backgroundColor: Color(0xFFFFFFFF),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Смотреть все",
                                        style: TextStyle(
                                          fontFamily: 'SNPro',
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
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
                                      color: Colors.black.withAlpha(40),
                                      blurRadius: 10,
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
                                      fontFamily: "Caveat",
                                      fontSize: 24,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Контейнер для нижнего меню
                    Container(
                      color: Colors.transparent,
                      height: 66,
                      child: Center(child: BottomMenu()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }, // Конец builder
    );
  }
}
