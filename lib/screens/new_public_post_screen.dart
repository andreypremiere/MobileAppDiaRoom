import 'package:dia_room/models/canvas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class NewPublicPostScreen extends StatefulWidget {
  const NewPublicPostScreen({super.key});

  @override
  State<NewPublicPostScreen> createState() {
    return NewPublicPostState();
  }
}

class NewPublicPostState extends State<NewPublicPostScreen> {
  final TextEditingController _namePostController = TextEditingController();
  final List<BlockPost> _blocks = [];

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
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: AppBar(
            backgroundColor: Color(0xFFB4B4B4),
            leading: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: SvgPicture.asset(
                'assets/icons/button_back.svg',
                width: 32,
                height: 32,
              ),
            ),
            title: Text(
              'Создание поста',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                fontFamily: 'SNPro',
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  print('Отправлен дальше');
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  backgroundColor: Color(0xFFC9C9C9),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Чем больше число, тем круглее
                    // Можно также добавить рамку самой кнопке:
                    // side: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
                child: Text(
                  'Далее',
                  style: TextStyle(
                    fontFamily: 'SNPro',
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
              SizedBox(width: 6),
            ],
          ),
        ),
        body: ListView(
          padding: EdgeInsets.all(8),
          children: [
            //
            // Название поста
            //
            TextField(
              controller: _namePostController,
              style: const TextStyle(
                fontFamily: 'SNPro',
                fontSize: 18,
                color: Colors.black,
              ),
              decoration: InputDecoration(
                // Текст-подсказка
                hintText: 'Название поста',
                hintStyle: const TextStyle(color: Colors.grey),
                // Внутренние отступы текста от краев рамки
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                // Убираем стандартное подчеркивание
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFFFFFFF),
                  ), // Светло-серая рамка
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFD1D1D1)),
                ),
                // Рамка при нажатии (в фокусе)
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFB4B4B4),
                    width: 1.5,
                  ), // Делаем чуть темнее или толще
                ),
                // filled: true,
                // fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            const Text("Контент поста:"),

            // Динамические блоки
            // Троеточие (...) "распаковывает" список блоков прямо сюда
            ..._blocks.map((block) => _buildBlock(block)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(BlockPost block) {
    return Container();
  }
}
