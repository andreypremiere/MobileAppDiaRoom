class UpdatingAvatarRequest {
  final String mimeType;

  const UpdatingAvatarRequest({required this.mimeType});

  factory UpdatingAvatarRequest.fromMap(Map<String, dynamic> map) {
    return UpdatingAvatarRequest(
      mimeType: map['mimeType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mimeType': mimeType,
    };
  }
}

