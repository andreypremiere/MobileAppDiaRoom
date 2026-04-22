import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/models/post_view/feed_post.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PostComponent extends StatefulWidget {
  final FeedPost post;

  const PostComponent({super.key, required this.post});

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
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.black.withAlpha(30),
        //     blurRadius: 12,
        //     spreadRadius: 0,
        //     // Смещение тени вниз для эффекта глубины
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Material(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(10),
        // Обрезка содержимого (картинки и InkWell) по радиусу углов
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            // Вызов колбэка
            print("Клик по посту!");
            context.push("/showPost/${widget.post.data.postId}");
          },
          child: SizedBox(
            width: double.infinity,
            // height: 260,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Сохранение пропорций изображения 16:9
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      // Картинка
                      CachedNetworkImage(
                        imageUrl: widget.post.data.preview ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,

                        placeholder: (context, url) => Container(
                          color: context.ui.containerColor,
                          child: const Center(child: CircularProgressIndicator()),
                        ),

                        errorWidget: (context, url, error) => Ink(
                          decoration: const BoxDecoration(
                            color: Color(0xFFE0E0E0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 40,
                              color: Color(0xFF888888),
                            ),
                          ),
                        ),
                      ),

                      Positioned(
                        left: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.ui.containerColor.withAlpha(85),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.post.data.category.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.ui.fontColorPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Нижняя часть карточки с аватаром и заголовком
                // Нижняя часть карточки с аватаром, заголовком и ником под ними
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Первая строка: Аватар + Название
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Круглый аватар
                          CachedNetworkImage(
                            imageUrl: widget.post.author.avatar,
                            imageBuilder: (context, imageProvider) => CircleAvatar(
                              radius: 20, // Ширина аватара будет 40 (radius * 2)
                              backgroundImage: imageProvider,
                            ),
                            placeholder: (context, url) => CircleAvatar(
                              radius: 20,
                              backgroundColor: context.ui.primaryColor,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            errorWidget: (context, url, error) => CircleAvatar(
                              radius: 20,
                              backgroundColor: context.ui.primaryColor,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.post.data.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: context.ui.fontColorPrimary
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. Вторая строка: Никнейм с отступом
                      // Отступ = 40 (ширина аватара) + 12 (SizedBox) = 52
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 52, top: 2),
                      //   child: Text(
                      //     widget.post.author.roomName,
                      //     style: const TextStyle(
                      //       color: Colors.black54,
                      //       fontSize: 14,
                      //       fontWeight: FontWeight.w400,
                      //       fontFamily: "SNPro",
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5, top: 4),
                  child: Row(
                    children: [
                      Text(
                        widget.post.author.roomName,
                        style: TextStyle(
                          color: context.ui.fontColorHint,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '${widget.post.stats.views}', // Количество просмотров
                        style: TextStyle(
                          color: context.ui.fontColorHint,
                          fontSize: 14,
                        ),
                      ),

                      // 1. Иконка просмотров
                      const SizedBox(width: 6),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        // Outlined версия обычно выглядит легче
                        size: 20,
                        color: context.ui.fontColorHint,
                      ),

                      const SizedBox(width: 10,),
                      // Расталкивает просмотры влево, а лайки вправо
                      Text(
                        '${widget.post.stats.likes}',
                        style: TextStyle(
                          color: context.ui.fontColorHint,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.favorite_border_rounded,
                        // Outlined версия обычно выглядит легче
                        size: 20,
                        color: context.ui.fontColorHint,
                      ),

                      // 2. Скругленный виджет лайков
                      // Container(
                      //   decoration: BoxDecoration(
                      //     color: Colors
                      //         .transparent, // Твой основной цвет элементов
                      //     // borderRadius: BorderRadius.circular(20), // Полное скругление
                      //     // boxShadow: [
                      //     //   BoxShadow(
                      //     //     color: Colors.black.withAlpha(20),
                      //     //     blurRadius: 4,
                      //     //     offset: const Offset(0, 2),
                      //     //   ),
                      //     // ],
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       // Количество лайков
                      //       Padding(
                      //         padding: const EdgeInsets.only(
                      //           left: 12,
                      //           right: 2,
                      //         ),
                      //         child: Text(
                      //           '${widget.post.stats.likes}',
                      //           style: const TextStyle(
                      //             color: Colors.black54,
                      //             fontSize: 14,
                      //           ),
                      //         ),
                      //       ),
                      //
                      //       // Кнопка лайка
                      //       GestureDetector(
                      //         onTap: () {
                      //           print('Лайк поставлен');
                      //         },
                      //         child: Container(
                      //           padding: const EdgeInsets.all(6),
                      //           decoration: const BoxDecoration(
                      //             // color: Colors.black12, // Легкое выделение области кнопки
                      //             shape: BoxShape.circle,
                      //           ),
                      //           child: const Icon(
                      //             Icons.favorite_border_rounded,
                      //             // Или Icons.favorite, если лайк поставлен
                      //             size: 24,
                      //             color: Color(
                      //               0xFF810202,
                      //             ), // Твой акцентный красный
                      //           ),
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
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
