import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AuthorShimmerTile extends StatelessWidget {
  const AuthorShimmerTile({super.key});

  @override
  Widget build(BuildContext context) {
    // Автоматически подстраиваем цвета под темную/светлую тему
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Row(
      mainAxisSize: MainAxisSize.min, // По контенту
      children: [
        // Скелет аватара
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: const CircleAvatar(
            radius: 18, // width & height = 36
            backgroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 10),
        // Скелет имени автора
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: 100,
            height: 18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }
}