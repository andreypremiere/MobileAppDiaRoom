import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

Widget buildStats(BuildContext context, int views, int likes) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        '${views}',
        style: TextStyle(color: context.ui.fontColorHint, fontSize: 13),
      ),
      const SizedBox(width: 4),
      Icon(Icons.remove_red_eye_outlined, size: 16, color: context.ui.fontColorHint),

      const SizedBox(width: 10),

      Text(
        '${likes}',
        style: TextStyle(color: context.ui.fontColorHint, fontSize: 13),
      ),
      const SizedBox(width: 4),
      Icon(Icons.favorite_border_rounded, size: 16, color: context.ui.fontColorHint),
    ],
  );
}