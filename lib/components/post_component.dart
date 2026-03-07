import 'package:flutter/material.dart';

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
      // Внешний контейнер только для тени
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        // Clip.antiAlias нужен здесь, чтобы скруглить углы картинки и InkWell
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            widget.onTap != null ? widget.onTap!() : print("Клик по посту!");
          },
          child: SizedBox(
            width: double.infinity,
            height: 260,
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Ink.image(
                    image: const NetworkImage(
                      'https://i.ytimg.com/vi/8pYzCQAgH6Y/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgZShlMA8=&amp;rs=AOn4CLB_SdsIPXNROLGTlBMTy3SFJY3PQg',
                    ),
                    fit: BoxFit.cover,
                    // Добавляем заглушку на время загрузки или ошибку, если нужно
                    // child: Container(color: Colors.black12),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 20,
                          backgroundColor: Color(0xFF722323),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Очень длинное название, которое переносится и обрезается',
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
