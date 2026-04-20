import 'package:flutter/material.dart';

enum AiCheckStatus {
  notChecked('Не проверялось', Icons.hourglass_empty_rounded, Colors.grey),
  checking('Идет проверка ИИ...', Icons.psychology_outlined, Colors.blue),
  passed('Проверка пройдена', Icons.check_circle_outline_rounded, Colors.green),
  warning('Есть замечания', Icons.report_problem_outlined, Colors.amber),
  failed('Не соответствует правилам', Icons.cancel_outlined, Colors.red);

  final String label;
  final IconData icon;
  final Color color;

  const AiCheckStatus(this.label, this.icon, this.color);

  static AiCheckStatus fromString(String value) {
    return AiCheckStatus.values.firstWhere(
          (e) => e.name == value,
      orElse: () => AiCheckStatus.notChecked,
    );
  }
}