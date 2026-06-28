class CheckVersionResponse {
  final String status;
  final String message;

  CheckVersionResponse({required this.status, required this.message});

  factory CheckVersionResponse.fromMap(Map<String, dynamic> map) {
    return CheckVersionResponse(
      status: map['status'] ?? '',
      message: map['message'] ?? ''
    );
  }
}