import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../components/post_component.dart';
import '../configuration/urls.dart';
import '../utils/utils.dart';

class PersonalPostsScreen extends StatefulWidget {
  const PersonalPostsScreen({super.key});

  @override
  State<PersonalPostsScreen> createState() {
    return _StatePersonalPostsScreen();
  }
}

class _StatePersonalPostsScreen extends State<PersonalPostsScreen> {
  String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                    ? NetworkImage(
                        createFullPathAvatar(objectStoragePath, avatarUrl!),
                      )
                    : NetworkImage(
                        createFullPathAvatar(
                          objectStoragePath,
                          defaultAvatarPath,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
              Text(
                'Room name',
                style: TextStyle(
                  fontFamily: 'SNPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: Color(0xFFFFA6A6).withAlpha(0),
          leading: IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(
              'assets/icons/button_back.svg',
              width: 30,
              height: 30,
            ),
          ),
        ),
        body: SingleChildScrollView(child: Column(
          spacing: 10,
          children: [
            PostComponent(),
            PostComponent(),
            PostComponent(),
            PostComponent(),
          ],
        ),),
      ),
    );
  }
}
