enum MessageStatus {
  sending,
  sent,
  failed;

  String toJson() => nameValue[this]!;
  static MessageStatus fromJson(String value) =>
      valueMap[value] ?? MessageStatus.sending;

  static const valueMap = {
    'sending': MessageStatus.sending,
    'sent': MessageStatus.sent,
    'failed': MessageStatus.failed,
  };

  static const nameValue = {
    MessageStatus.sending: 'sending',
    MessageStatus.sent: 'sent',
    MessageStatus.failed: 'failed',
  };
}