class UpdatingTextFieldRequest {
  final String value;

  const UpdatingTextFieldRequest({required this.value});

  factory UpdatingTextFieldRequest.fromMap(Map<String, dynamic> map) {
    return UpdatingTextFieldRequest(
      value: map['value'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'value': value,
    };
  }
}

