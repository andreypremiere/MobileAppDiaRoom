import 'package:dia_room/models/enums/categories.dart';
import 'package:dia_room/models/post_creator/post_draft.dart';
import 'package:dia_room/models/post_creator/workshop_link.dart';

import 'block_post.dart';

class PublicationPost {
  String? id;
  String title;
  String? previewPublicURL;
  Map<String, dynamic> metadata;
  WorkshopLink workshopLink = WorkshopLink();

  Categories categorySlug;

  List<BlockUpload>? payload;

  List<String> hashtags;

  PublicationPost({
    this.id,
    required this.title,
    this.previewPublicURL,
    Map<String, dynamic>? metadata,
    required this.categorySlug,
    this.payload,
    List<String>? hashtags,
    WorkshopLink? workshopLink
  }) : metadata = metadata ?? {},
       hashtags = hashtags ?? [], workshopLink = workshopLink ?? WorkshopLink();

  factory PublicationPost.fromDraft({
    required PostDraft draft,
  }) {
    return PublicationPost(
      id: null,
      title: draft.name,
      previewPublicURL: null,
      // На старте это локальный путь
      categorySlug: draft.category,
      hashtags: List.from(draft.hashtags),
      payload: null,
      workshopLink: draft.workshopLink
    );
  }

  List<Map<String, dynamic>> payloadToJson() {
    if (payload == null || payload!.isEmpty) {
      return [];
    }

    return payload!.map((block) => block.toJson()).toList();
  }
}
