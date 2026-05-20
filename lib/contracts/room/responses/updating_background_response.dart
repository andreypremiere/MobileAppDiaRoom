class UpdatingBackgroundResponse {
  final String uploadUrl;
  final String publicUrl;

  const UpdatingBackgroundResponse({
    required this.uploadUrl,
    required this.publicUrl,
  });

  factory UpdatingBackgroundResponse.fromMap(Map<String, dynamic> map) {
    return UpdatingBackgroundResponse(
      uploadUrl: map['uploadUrl'] as String? ?? '',
      publicUrl: map['publicUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uploadUrl': uploadUrl,
      'publicUrl': publicUrl,
    };
  }
}