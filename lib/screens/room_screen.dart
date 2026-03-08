import 'package:dia_room/components/bottom_menu_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:dia_room/models/room.dart';
import 'package:dia_room/utils/utils.dart';
import 'package:dia_room/configuration/urls.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() {
    return _RoomState();
  }
}

class _RoomState extends State<RoomScreen> {
  // final TextEditingController _codeController = TextEditingController();
  late Room room;
  bool _isBioVisible = false;

  @override
  void initState() {
    super.initState();
    // 2. Присваиваем значение при инициализации состояния
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
      bio:
          "Lorem Ipsum - это просто фиктивный текст для полиграфической и наборной промышленности. Lorem Ipsum является стандартным фиктивным текстом в отрасли с 1500-х годов, когда неизвестный типограф взял образец шрифта и переработал его, чтобы создать книгу с образцами шрифтов. Он пережил не только пять столетий, но и переход на электронный набор текста, оставаясь практически неизменным. Он был популяризирован в 1960-х годах с выпуском листов Letraset, содержащих отрывки из Lorem Ipsum, и совсем недавно с появлением настольного издательского программного обеспечения, такого как Aldus PageMaker, включающего версии Lorem Ipsum.",
      // avatarUrl: "avatars/8cfbc1a1-9588-4295-b016-76e8aa028aef/8cfbc1a1-9588-4295-b016-76e8aa028aef_1772691313.jpg",
      settings: <String, dynamic>{},
      followersCount: 632,
      followingCount: 3,
    );
  }

  // @override
  // void dispose() {
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        // backgroundColor: Color(0xFFC9BBBB),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Color(0xFFFFA6A6).withAlpha(0),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
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
                // Верхняя шторка
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
                              shadows: [
                                Shadow(
                                  blurRadius: 15.0,
                                  color: Colors.black54,
                                  offset: Offset(1.0, 1.0),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                // Контент под шторкой
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // Прижать содержимое влево
                            children: [
                              const SizedBox(height: 10),
                              // Категории
                              SizedBox(
                                width: double.infinity,
                                child: Wrap(
                                  spacing: 8,
                                  alignment: WrapAlignment.start,
                                  children: room.categories.map((category) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 0,
                                        vertical: 4,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        // mainAxisAlignment: MainAxisAlignment.center,
                                        spacing: 4,
                                        children: [
                                          SvgPicture.asset(
                                            'assets/icons/${category.slug}.svg',
                                            width: 16,
                                            height: 16,
                                          ),
                                          Text(
                                            category.name,
                                            style: TextStyle(
                                              fontSize: 14,
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
                              const SizedBox(height: 5),
                              // Описание
                              if (room.bio != null && room.bio!.isNotEmpty) ...[
                                _isBioVisible
                                    ? Padding(
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
                                      )
                                    : const SizedBox(width: double.infinity),
                                // Пустота, когда скрыто

                                // 3. Кнопка-переключатель
                                InkWell(
                                  splashColor: Colors.transparent,
                                  // Убирает круги
                                  highlightColor: Colors.transparent,
                                  // Убирает блик при зажатии
                                  hoverColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      _isBioVisible = !_isBioVisible;
                                    });
                                  },
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
                              // Кнопка Дневник
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 60),
                                  alignment: Alignment.centerLeft,
                                  // padding: const EdgeInsets.all(6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  backgroundColor: Color(0xFF810202),
                                ),
                                onPressed: () {},
                                child: Text(
                                  "Дневник",
                                  style: TextStyle(
                                    fontFamily: "Caveat",
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Витрина
                        const SizedBox(height: 12),
                        Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 14,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Color(0xFFE1DFDA),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(30),
                                // Очень слабая прозрачность
                                blurRadius: 14,
                                // Размытие
                                spreadRadius: 4,
                                // Растяжение
                                offset: const Offset(0, 0), // Смещение вниз
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Витрина',
                                // textAlign: TextAlign.start ,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 26,
                                  fontFamily: 'Caveat',
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () {
                                    context.push('/roomPosts');
                                  },
                                  child: Text(
                                    "Смотреть все",
                                    style: TextStyle(
                                      fontFamily: 'SNPro',
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Мастерская
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(40),
                                  // Прозрачность тени
                                  blurRadius: 10,
                                  // Размытие
                                  spreadRadius: 4,
                                  // Растяжение
                                  offset: const Offset(0, 0), // Смещение вниз
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 60),
                                alignment: Alignment.centerLeft,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: const Color(0xFFE1DFDA),
                                elevation:
                                    0, // ОБЯЗАТЕЛЬНО: убираем родную тень кнопки
                              ),
                              onPressed: () {},
                              child: const Text(
                                'Мастерская',
                                style: TextStyle(
                                  fontFamily: "Caveat",
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
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
                Container(
                  color: Colors.transparent,
                  height: 66,
                  width: double.infinity,
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
