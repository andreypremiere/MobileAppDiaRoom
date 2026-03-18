// Canvas представляет собой класс содержимого поста
import 'package:flutter/material.dart';

// class Canvas {
//   final String id;
//   final List<BlockPost> payload;
//
//   Canvas({required this.id, required this.payload});
//
//   int getMaxId() {
//     int maxId = 0;
//     for (var block in payload) {
//       if (block.id > maxId) maxId = block.id;
//     }
//     return maxId;
//   }
//
//   int newId() {
//     return getMaxId() + 1;
//   }
// }

enum BlockPostType {
  text,
  photos,
  videos,
  audio,
  file
}

extension BlockPostTypeExtension on BlockPostType {
  String get label {
    switch (this) {
      case BlockPostType.text: return 'Текст';
      case BlockPostType.photos: return 'Фотографии';
      case BlockPostType.videos: return 'Видео';
      case BlockPostType.audio: return 'Аудио';
      case BlockPostType.file: return 'Файл';
    }
  }

  IconData get icon {
    switch (this) {
      case BlockPostType.text: return Icons.text_fields;
      case BlockPostType.photos: return Icons.photo;
      case BlockPostType.videos: return Icons.videocam;
      case BlockPostType.audio: return Icons.audiotrack;
      case BlockPostType.file: return Icons.description;
    }
  }
}

// class BlockPost {
//   final int id;
//   final BlockPostType type;
//
//   BlockPost({required this.id, required this.type});
// }

// class BlockText extends BlockPost {
//   String text;
//   final Map<String, dynamic> metadata; // fontSize, fontColor, fontItalic, fontWeight, default
//
//   BlockText({required super.id, required this.text, this.metadata = const {}}) : super(
//     type: BlockPostType.text
//   );
// }
//
// class Photo {
//   String url;
//   final Map<String, dynamic> metadata; // size
//
//   Photo({required this.url, this.metadata = const {}});
// }
//
// class BlockPhotos extends BlockPost {
//   final List<Photo> data;
//   final Map<String, dynamic> metadata; // method_showing
//
//   BlockPhotos({required super.id, required this.data, required this.metadata}) :
//       super(
//         type: BlockPostType.photos
//       );
// }
//
// class Video {
//   String url;
//   final Map<String, dynamic> metadata; // preview_url, duration, size, quality
//
//   Video({required this.url, required this.metadata});
// }
//
// class BlockVideos extends BlockPost {
//   final List<Video> data;
//
//   BlockVideos({required super.id, required this.data}) :
//         super(
//           type: BlockPostType.videos
//       );
// }
//
// class BlockAudio extends BlockPost {
//   String url;
//   String audioName;
//   final Map<String, dynamic> metadata; // type(wav, mp3), duration, size, showingFileName
//
//   BlockAudio({required super.id, required this.url, this.audioName = "default", required this.metadata}) :
//         super(
//           type: BlockPostType.audio
//       );
// }
//
// class BlockFile extends BlockPost {
//   String url;
//   String fileName;
//   final Map<String, dynamic> metadata; // type(docx, excel, ...), size, showingFileName
//
//   BlockFile({required super.id, required this.url, this.fileName = "default", required this.metadata}) :
//         super(
//           type: BlockPostType.file
//       );
// }
