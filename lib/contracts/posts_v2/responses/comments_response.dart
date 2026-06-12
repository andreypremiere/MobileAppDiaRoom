import 'comment_response.dart';

class CommentsResponse {
  final List<CommentResponse> comments;

  const CommentsResponse({required this.comments});

  factory CommentsResponse.fromMap(Map<String, dynamic> map) {
    final List<dynamic>? rawComments = map['comments'] as List<dynamic>?;

    if (rawComments == null) {
      return const CommentsResponse(comments: []);
    }

    return CommentsResponse(
      comments: rawComments
          .map((item) => CommentResponse.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }
}