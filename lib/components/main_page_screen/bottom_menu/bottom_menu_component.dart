import 'package:dia_room/utils/app_theme.dart';
import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'bottom_menu_item.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      decoration: ShapeDecoration(
        color: context.ui.containerColor,
        shape: const StadiumBorder(),
        shadows: [
          BoxShadow(
            blurRadius: 8,
            color: Colors.black.withAlpha(25),
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          BottomMenuItem(
            icon: Icons.person,
            onPressed: () {
              final roomId = context.read<AuthProvider>().roomId;
              if (roomId != null) context.push('/room/$roomId');
            },
          ),
          BottomMenuItem(
            icon: Icons.people,
            onPressed: () {
              context.push('/diaries');
            },
          ),
          BottomMenuItem(
            icon: Icons.search_rounded,
            onPressed: () {
              context.push('/search');
            },
          ),
          BottomMenuItem(
            icon: Icons.settings_rounded,
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
    );
  }
}
