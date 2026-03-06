import 'package:flutter/material.dart';

class PostComponent extends StatefulWidget {
  const PostComponent({super.key});

  @override
  State<PostComponent> createState() {
    return _StatePostComponent();
  }
}

class _StatePostComponent extends State<PostComponent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFFFFFFF),
        boxShadow: [BoxShadow(
          color: Colors.black.withAlpha(30),
          blurRadius: 18,
          spreadRadius: 4
        )]
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300], // Цвет заглушки
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://i.ytimg.com/vi/8pYzCQAgH6Y/maxresdefault.jpg?sqp=-oaymwEmCIAKENAF8quKqQMa8AEB-AH-CYAC0AWKAgwIABABGGUgZShlMA8=&amp;rs=AOn4CLB_SdsIPXNROLGTlBMTy3SFJY3PQg',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10),child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(radius: 20, backgroundColor: Color(0xFF722323)),
              const SizedBox(width: 12),
              Expanded(child: Text('Очень длинное название которое точно никогда не влезет в этот контейнер почтому что я написал тут слишком много ненужных слов, которые уже выдали ошибку',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  fontFamily: 'SNPro'
                ),))
            ],
          ),))
        ],
      ),
    );
  }
}
