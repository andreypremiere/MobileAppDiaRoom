class AuthResponse {
  final bool success;
  final String? message; // Описание ошибки для юзера
  final dynamic data; // Данные (например, JWT или UUID)

  AuthResponse({required this.success, this.message, this.data});
}