import 'package:dia_room/contracts/diary/response/getting_messages.dart';

class UpdatingStatus {
  final MessagePresentation? messagePresentation;

  UpdatingStatus({this.messagePresentation});

  factory UpdatingStatus.fromMap(Map<String, dynamic> map) {
    return UpdatingStatus(
      messagePresentation: MessagePresentation.fromMap(map['message'])
    );
  }
}