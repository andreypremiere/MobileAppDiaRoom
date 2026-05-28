class UpdatingBackgroundRequest {
  final String mimeType;

  const UpdatingBackgroundRequest({required this.mimeType});

  factory UpdatingBackgroundRequest.fromMap(Map<String, dynamic> map) {
    return UpdatingBackgroundRequest(
      mimeType: map['mimeType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'mimeType': mimeType,
    };
  }
}

