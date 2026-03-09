import 'package:flutter/material.dart';

// PostComponent представляет собой карточку поста с изображением и информацией об авторе
class PostComponent extends StatefulWidget {
  final VoidCallback? onTap;

  const PostComponent({super.key, this.onTap});

  @override
  State<PostComponent> createState() {
    return _StatePostComponent();
  }
}

class _StatePostComponent extends State<PostComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // Внешний контейнер для создания мягкой тени вокруг карточки
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            spreadRadius: 0,
            // Смещение тени вниз для эффекта глубины
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // Обрезка содержимого (картинки и InkWell) по радиусу углов
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Вызов колбэка
            widget.onTap != null ? widget.onTap!() : print("Клик по посту!");
          },
          child: SizedBox(
            width: double.infinity,
            height: 260,
            child: Column(
              children: [
                // Сохранение пропорций изображения 16:9
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Ink.image(
                    image: const NetworkImage(
                      'https://i.ytimg.com/vi/8pYzCQAgH6Y/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgZShlMA8=&amp;rs=AOn4CLB_SdsIPXNROLGTlBMTy3SFJY3PQg',
                    ),
                    // Растягивание изображения на всю доступную область
                    fit: BoxFit.cover,
                  ),
                ),
                // Нижняя часть карточки с аватаром и заголовком
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        // Круглый аватар пользователя
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF722323),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Очень длинное название, которое переносится и обрезается',
                            // Ограничение текста двумя строками с многоточием
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w500),
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
      ),
    );
  }
}
