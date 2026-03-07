import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../components/bottom_menu_component.dart';
import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/utils.dart';

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
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    // Слушаем изменение фокуса
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    // Слушаем ввод текста, чтобы крестик появлялся только когда есть что стирать
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        extendBody: true,
        body: CustomScrollView(
          slivers: [
            // Твой "уезжающий" контейнер превращается в SliverAppBar
            SliverAppBar(
              toolbarHeight: 60,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              floating: true,
              snap: true,
              // pinned: false,
              elevation: 0,
              titleSpacing: 0,
              title:
                  // Container(
                  //   height: 60,
                  //   width: double.infinity,
                  //   color: Colors.blue,
                  //   alignment: Alignment.topLeft,
                  //   child: const Text(
                  //     'Заголовок',
                  //     style: TextStyle(fontSize: 20, color: Colors.white),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 6,
                    ),
                    child: Row(
                      children: [
                        // Основное поле ввода
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
                              // Крестик внутри поля (справа)
                              suffixIcon: (_isFocused)
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 32,
                                        color: Color(0xFF595959),
                                      ),
                                      onPressed: () {
                                        _controller.clear();
                                        _focusNode.unfocus(); // Снимаем фокус
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(width: 4),

                        // Кнопка "Найти" снаружи
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _isFocused
                              ? 80
                              : 0, // Плавное появление ширины
                          child: _isFocused
                              ? ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
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
              // Здесь потом добавлять выбор категорий или фильтр
              // bottom: PreferredSize(
              //   preferredSize: Size(double.infinity, 20),
              //   child: Container(
              //     height: 20,
              //     width: double.infinity,
              //     color: Color(0xFF793232),
              //   ),
              // ),
            ),

            // Твой список постов
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 2),
                sliver: SliverList(
                delegate: SliverChildListDelegate([
                  for (int i=0; i <= 10; i++) ...[
                    
                    PostComponent(onTap: () {
                      print("Пользователь нажал на пост, переходим...");
                      // Здесь добавить навигация
                    },),
                    const SizedBox(height: 10),
                  ],
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 58)
                ]),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom:
                MediaQuery.of(context).padding.bottom +
                3, // Безопасная зона iOS/Android
            // left: 20,
            // right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [BottomMenu()],
          ),
        ),
      ),
    );
  }
}
