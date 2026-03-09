import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../components/bottom_menu_component.dart';
import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/auth_service.dart';
import '../utils/utils.dart';

// MainPageScreen — основной экран ленты с поиском и списком постов
class MainPageScreen extends StatefulWidget {
  const MainPageScreen({super.key});

  @override
  State<MainPageScreen> createState() {
    return _StateMainPageScreen();
  }
}

class _StateMainPageScreen extends State<MainPageScreen> {
  String? avatarUrl;
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false; // Состояние фокуса для изменения UI поиска

  @override
  void initState() {
    super.initState();
    // Слушаем изменение фокуса, чтобы скрывать/показывать кнопку поиска
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    // Слушаем ввод текста для обновления состояния (например, для иконки очистки)
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Освобождение ресурсов контроллеров
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Получение данных пользователя через Provider
    final user = context.watch<AuthProvider>().user;

    return GestureDetector(
      // Скрытие клавиатуры при тапе по любому месту экрана
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        // Позволяет контенту просвечивать под прозрачным BottomMenu
        body: CustomScrollView(
          slivers: [
            // SliverAppBar реализует эффект "уезжающей" при скролле шапки
            SliverAppBar(
              toolbarHeight: 60,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              floating: true,
              // Появляется сразу при скролле вверх
              snap: true,
              // Доводит анимацию до конца при легком движении
              elevation: 0,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                child: Row(
                  children: [
                    // Основное поле ввода поиска
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        style: const TextStyle(
                          fontFamily: "SNPro",
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                        decoration: InputDecoration(
                          hintText: "Поиск",
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 12,
                          ),
                          fillColor: const Color(0xFFFFFFFF),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          // Иконка "крестик" появляется только в фокусе
                          suffixIcon: (_isFocused)
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 32,
                                    color: Color(0xFF595959),
                                  ),
                                  onPressed: () {
                                    _controller.clear();
                                    _focusNode.unfocus();
                                  },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),

                    // Анимированная кнопка "Найти", плавно выезжающая справа
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isFocused ? 80 : 0,
                      // Динамическое изменение ширины
                      child: _isFocused
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                  horizontal: 2,
                                ),
                                backgroundColor: const Color(0xFF722323),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                print("Ищем: ${_controller.text}");
                                _focusNode.unfocus();
                              },
                              child: const Text(
                                "Найти",
                                style: TextStyle(
                                  fontFamily: "SNPro",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFFFFFFFF),
                                ),
                                maxLines: 1,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ),

            // Список постов внутри Sliver-структуры
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Цикл для генерации тестовых данных ленты
                  for (int i = 0; i <= 10; i++) ...[
                    PostComponent(
                      onTap: () {
                        context.push('/showPost');
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                  // Отступ снизу, чтобы контент не перекрывался меню
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 58),
                ]),
              ),
            ),
          ],
        ),
        // Фиксированное нижнее меню с учетом безопасных зон (Safe Area)
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [BottomMenu()],
          ),
        ),
      ),
    );
  }
}
