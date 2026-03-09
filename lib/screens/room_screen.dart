import 'package:dia_room/components/bottom_menu_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dia_room/models/room.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:dia_room/configuration/urls.dart';

// RoomScreen отображает детальную информацию о конкретной комнате
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<RoomScreen> {
  late Room room; // Объект комнаты, инициализируемый в initState
  bool _isBioVisible = false; // Состояние видимости длинного описания (био)

  @override
  void initState() {
    super.initState();
    // Инициализация моковых данных для верстки экрана
    room = Room(
      id: "8cfbc1a1-9588-4295-b016-76e8aa028aef",
      userId: "8cfbc1a1-9588-4295-b016-76e8aa028aegh",
      roomName: "Pretty room",
      roomNameId: "pretty_room_8392",
      categories: [
        Category(slug: 'visual-arts', name: 'Арт и Иллюстрация'),
        Category(slug: 'video-production', name: 'Видеопроизводство'),
        Category(slug: 'photography', name: 'Фотография'),
      ],
      bio: "Lorem Ipsum - это просто фиктивный текст...",
      settings: <String, dynamic>{},
      followersCount: 632,
      followingCount: 3,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      image: AssetImage('assets/images/background_profile.png'),
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
                            "Room name",
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  child: const Center(child: Text("Спонсор")),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
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
                              if (room.bio != null && room.bio!.isNotEmpty) ...[
                                if (_isBioVisible)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 4,
                                    ),
                                    child: Text(
                                      room.bio!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Caveat',
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
                                  minimumSize: const Size(double.infinity, 60),
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
                              const Text(
                                'Витрина',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  fontFamily: 'Caveat',
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  onPressed: () => context.push('/roomPosts'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
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
                                minimumSize: const Size(double.infinity, 60),
                                alignment: Alignment.centerLeft,
                                backgroundColor: const Color(0xFFE1DFDA),
                                elevation:
                                    0, // Убираем стандартную тень кнопки в пользу BoxDecoration
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
  }
}
