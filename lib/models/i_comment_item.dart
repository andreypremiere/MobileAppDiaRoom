import '../../../models/post_view/author.dart';

abstract class ICommentItem {
  String get id;
  String get text;
  DateTime get createdAt;
  Author? get author;
  String get formattedDate;
}