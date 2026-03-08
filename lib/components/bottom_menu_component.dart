import 'package:dia_room/utils/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class BottomMenu extends StatelessWidget {
  const BottomMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [BoxShadow(
          blurRadius: 10,
          color: Colors.black.withAlpha(30),
          spreadRadius: 4
        )]
      ),
      height: 52,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // IconButton(
          //   onPressed: () {},
          //   icon: SvgPicture.asset(
          //     'assets/icons/tape.svg',
          //     width: 30,
          //     height: 30,
          //   ),
          // ),
          IconButton(
            onPressed: () {
              context.push('/room');
            },
            icon: SvgPicture.asset(
              'assets/icons/profile.svg',
              width: 30,
              height: 30,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/subs.svg',
              width: 30,
              height: 30,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 30,
              height: 30,
            ),
          ),
        ],
      ),
    );
  }
}