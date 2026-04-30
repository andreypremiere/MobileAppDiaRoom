// components/room/room_action_button.dart
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class RoomActionButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const RoomActionButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          alignment: Alignment.centerLeft,
          backgroundColor: context.ui.sectionButtonColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            fontFamily: 'Caveat',
            color: context.ui.fontColorLight,
          ),
        ),
      ),
    );
  }
}