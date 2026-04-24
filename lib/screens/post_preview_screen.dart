import 'dart:io';
import 'package:dia_room/components/app_bar_button.dart';
import 'package:dia_room/components/auth_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../components/showing_post/photos_block_widget.dart';
import '../components/showing_post/showing_canvas.dart';
import '../components/showing_post/text_block_widget.dart';
import '../components/showing_post/video_preview_widget.dart';
import '../models/enums/post_types.dart';
import '../models/post_creator/block_text.dart';
import '../models/post_creator/block_photos.dart';
import '../models/post_creator/block_video.dart';
import '../models/post_creator/post_draft.dart';
import '../utils/utils.dart';


class PostPreviewScreen extends StatelessWidget {
  final PostDraft postDraft;

  const PostPreviewScreen({super.key, required this.postDraft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back_rounded,
                size: context.ui.iconSizePanel),
            color: context.ui.fontColorPrimary,
          ),
          title: Text(
            'Предпросмотр',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: context.ui.fontColorPrimary
            ),
          ),
          actions: [
            AppBarButton(
              text: 'Далее',
              onPressed: () {
                context.push('/set_settings');
              },
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
      body: ShowingCanvas(blocks: postDraft.blocks,),
    );
  }
}