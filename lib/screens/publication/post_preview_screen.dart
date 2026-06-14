import 'package:dia_room/components/new_public_post/app_bar_button.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../components/general/app_back_button.dart';
import '../../components/showing_post/showing_canvas.dart';
import '../../models/post_creator/post_draft.dart';


class PostPreviewScreen extends StatelessWidget {
  final PostDraft postDraft;

  const PostPreviewScreen({super.key, required this.postDraft});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ui.viewingPostColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: context.ui.appBarColor,
          leading: AppBackButton(),
          title: Text(
            'Предпросмотр',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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