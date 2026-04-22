// import 'package:dia_room/models/enums/ai_post_types.dart';
// import 'package:dia_room/models/enums/post_categories.dart';
// import 'package:dia_room/models/enums/post_status.dart';
// import 'package:dia_room/models/post_creator/post_draft.dart';
//
// import 'block_photos.dart';
// import 'block_post.dart';
// import 'block_text.dart';
// import 'block_video.dart';
//
// class PublicationPost {
//   String? id;
//   PostStatus postStatus;
//   AiCheckStatus aiCheckStatus;
//   String title;
//   String? previewPublicURL;
//   Map<String, dynamic> metadata;
//
//   PostCategory categorySlug;
//
//   List<BlockUpload>? payload; // по началу может быть ноль, но нужна проверка
//
//   List<String> hashtags;
//
//   PublicationPost({
//     this.id,
//     this.postStatus = PostStatus.pending,
//     this.aiCheckStatus = AiCheckStatus.notChecked,
//     required this.title,
//     this.previewPublicURL,
//     Map<String, dynamic>? metadata,
//     required this.categorySlug,
//     this.payload,
//     List<String>? hashtags,
//   }) : metadata = metadata ?? {},
//        hashtags = hashtags ?? [];
//
//   factory PublicationPost.fromDraft({
//     required PostDraft draft,
//     required String roomId,
//   }) {
//     return PublicationPost(
//       id: null,
//       title: draft.name,
//       previewPublicURL: null,
//       // На старте это локальный путь
//       categorySlug: draft.category,
//       hashtags: List.from(draft.hashtags),
//       metadata: Map.from(draft.metadata),
//       payload: null,
//     );
//   }
//
//   List<Map<String, dynamic>> payloadToJson() {
//     if (payload == null || payload!.isEmpty) {
//       return [];
//     }
//
//     return payload!.map((block) => block.toJson()).toList();
//   }
// }
