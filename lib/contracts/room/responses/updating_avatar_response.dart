class UpdatingAvatarResponse {
  final String uploadUrl;
  final String publicUrl;

  const UpdatingAvatarResponse({
    required this.uploadUrl,
    required this.publicUrl,
  });

  factory UpdatingAvatarResponse.fromMap(Map<String, dynamic> map) {
    return UpdatingAvatarResponse(
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