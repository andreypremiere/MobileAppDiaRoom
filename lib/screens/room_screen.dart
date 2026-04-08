import 'package:dia_room/components/bottom_menu_component.dart';
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
  late Future<Map<String, dynamic>?> _roomFuture;
  late String? currentRoomId;
  bool _isBioVisible = false; // Состояние, показано ли bio или нет

  @override
  void initState() {
    super.initState();
    // Инициализируем запрос при старте.
    // context.read можно использовать в initState, если не слушать изменения.
    // currentRoomId = context.read<AuthProvider>().roomId;
    // final token = context.read<AuthProvider>().accessToken ?? "";
    // _roomFuture = api.getRoomByRoomId(widget.roomId, token);
    _roomFuture = Future.value({});
    currentRoomId = 'dlfj';
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
        // final Room? room = Room.fromJson(snapshot.data!);

        final room = Room(
          id: 'room-uuid-12345',
          userId: 'user-uuid-67890',
          roomName: 'Dev & Chill',
          roomNameId: 'dev_chill_room', // Тот самый уникальный ID комнаты
          categories: [Category(slug: 'visual-arts', name: "Изобразительное искусство")],
          avatarUrl: 'https://api.diaroom.com/uploads/avatars/room1.jpg',
          backgroundImage: 'https://api.diaroom.com/uploads/bg/room1_bg.png',
          bio: 'Обсуждаем микросервисы на Go и фронтенд на Flutter.',
          settings: {
          },
          followersCount: 1250,
          followingCount: 42,
        );

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
              backgroundColor: Colors.transparent,           // полностью прозрачный
              elevation: 0,
              scrolledUnderElevation: 0,                     // ← вот главное!
              shadowColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              forceMaterialTransparency: true,
              // backgroundColor: const Color(0xFFFFA6A6).withAlpha(0),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: SvgPicture.asset(
                  'assets/icons/button_back.svg',
                  width: 30,
                  height: 30,
                ),
              ),
              actions: [
                // Здесь исправить на провайдера
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
            AspectRatio(
            aspectRatio: 4 / 3, // Просто задаем пропорцию
              child: Container(
                      width: double.infinity,
                      // height: 220,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:  AssetImage(
                            'assets/images/background_profile.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                        // color: Color(0xFFCB6C6C),
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
                                          // (room.avatarUrl != null &&
                                          //     room.avatarUrl!.isNotEmpty)
                                          // ? NetworkImage(
                                          //     createFullPathAvatar(
                                          //       objectStoragePath,
                                          //       room.avatarUrl!,
                                          //     ),
                                          //   )
                                          // :
                                          NetworkImage(
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
                    ),),
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
                                    borderRadius: BorderRadius.circular(16),        // чуть округлил для современного вида
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
                                    padding: const EdgeInsets.all(16),               // общие отступы внутри карточки
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // 1. Категории как чипсы в горизонтальном скролле
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: room.categories.map((category) {
                                              return Container(
                                                margin: const EdgeInsets.only(right: 10),
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFE1DFDA),
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withAlpha(30),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
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
                                                        fontWeight: FontWeight.w600,
                                                        fontFamily: 'SNPro',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ),

                                        if (room.categories.isNotEmpty) const SizedBox(height: 10),

                                        Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          child: GestureDetector(
                                            onTap: () async {
                                              final idToCopy = room.roomNameId; // без символа @

                                              await Clipboard.setData(ClipboardData(text: idToCopy));

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
                                              '@${room.roomNameId}',
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
                                        if (room.bio != null && room.bio!.isNotEmpty)
                                          Center(
                                            child: InkWell(
                                              onTap: () => setState(() => _isBioVisible = !_isBioVisible),
                                              borderRadius: BorderRadius.circular(8),
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                                child: Text(
                                                  _isBioVisible ? "Скрыть описание" : "Показать описание",
                                                  style: const TextStyle(
                                                    color: Color(0xFF797979),
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                    fontFamily: 'SNPro',
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                        // const SizedBox(height: 12),

                                        // 4. Само описание (выровнено слева)
                                        if (_isBioVisible && room.bio != null && room.bio!.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(left: 4, right: 4),
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
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE1DFDA), // Твой цвет фона (мастерской/витрины)
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(25), // Очень легкая тень
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${room.followersCount}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  fontFamily: 'SNPro',
                                                ),
                                              ),
                                              const Text(
                                                'подписчики',
                                                style: TextStyle(fontSize: 12, color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12), // Отступ между карточками
                                      // Виджет Подписки
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE1DFDA),
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withAlpha(25),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                '${room.followingCount}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                  fontFamily: 'SNPro',
                                                ),
                                              ),
                                              const Text(
                                                'подписки',
                                                style: TextStyle(fontSize: 12, color: Colors.black54),
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
                                  SizedBox(height: 10,),

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
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
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

                                          const SizedBox(height: 10),

                                          // Кнопка "Смотреть все" — теперь коричневая, как "Дневник"
                                          SizedBox(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF810202),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                              ),
                                              onPressed: () => context.push('/roomPosts'),
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
