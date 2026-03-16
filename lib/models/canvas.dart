// Canvas представляет собой класс содержимого поста
class Canvas {
  final String id;
  final List<BlockPost> payload;

  Canvas({required this.id, required this.payload});

  int getMaxId() {
    int maxId = 0;
    for (var block in payload) {
      if (block.id > maxId) maxId = block.id;
    }
    return maxId;
  }

  int newId() {
    return getMaxId() + 1;
  }
}

enum BlockPostType {
  text,
  photo,
  photos,
  video,
  videos,
  audio,
  file
}

class BlockPost {
  final int id;
  final BlockPostType type;

  BlockPost({required this.id, required this.type});
}

class BlockText extends BlockPost {
  final String text;
  final Map<String, dynamic> metadata; // fontSize, fontColor, fontItalic, fontWeight, default

  BlockText({required super.id, required this.text, this.metadata = const {}}) : super(
    type: BlockPostType.text
  );
}

class BlockPhoto extends BlockPost {
  final String url;
  final Map<String, dynamic> metadata; // size

  BlockPhoto({required super.id, required this.url, this.metadata = const {}}) :
      super(
        type: BlockPostType.photo
      );
}

class BlockPhotos extends BlockPost {
  final List<BlockPhoto> data;
  final Map<String, dynamic> metadata; // method_showing

  BlockPhotos({required super.id, required this.data, required this.metadata}) :
      super(
        type: BlockPostType.photos
      );
}

class BlockVideo extends BlockPost {
  final String url;
  final Map<String, dynamic> metadata; // preview_url, duration, size, quality

  BlockVideo({required super.id, required this.url, required this.metadata}) :
        super(
          type: BlockPostType.video
      );
}

class BlockVideos extends BlockPost {
  final List<BlockVideo> data;

  BlockVideos({required super.id, required this.data}) :
        super(
          type: BlockPostType.videos
      );
}

class BlockAudio extends BlockPost {
  final String url;
  final String audioName;
  final Map<String, dynamic> metadata; // type(wav, mp3), duration, size, showingFileName

  BlockAudio({required super.id, required this.url, this.audioName = "default", required this.metadata}) :
        super(
          type: BlockPostType.audio
      );
}

class BlockFile extends BlockPost {
  final String url;
  final String fileName;
  final Map<String, dynamic> metadata; // type(docx, excel, ...), size, showingFileName

  BlockFile({required super.id, required this.url, this.fileName = "default", required this.metadata}) :
        super(
          type: BlockPostType.file
      );
}
