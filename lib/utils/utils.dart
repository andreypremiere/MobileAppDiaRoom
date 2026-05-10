// Функция для создания полного пути из базового url и postfix
import 'package:flutter/material.dart';

import '../configuration/urls.dart';

String createFullPathAvatar(String prefix, String postfix) {
  return "$prefix/$postfix";
}

String getFullUrl(String path) {
  if (path.startsWith('http')) return path;
  return '$s3BaseUrl$path';
}

String formatDuration(Duration duration) {
  if (duration == Duration.zero) return "-:--";

  String twoDigits(int n) => n.toString().padLeft(2, "0");

  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  if (hours > 0) {
    // Формат H:MM:SS
    return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
  } else {
    // Формат M:SS
    return "${duration.inMinutes}:${twoDigits(seconds)}";
  }
}

FontWeight getFontWeight(int value) {
  switch (value) {
    case 400: return FontWeight.w400;
    case 600: return FontWeight.w600;
    case 800: return FontWeight.w800;
    default: return FontWeight.w400;
  }
}

void printError(String text) {
  // Добавляем красный цвет и жирность
  print('\x1B[31;1m$text\x1B[0m');
}

String? isValidRoomId(String input) {
  // Если строка пустая или слишком короткая, сразу false
  if (input.isEmpty) return "id не должен быть пустой : (";

  if (input.length > 100) {
    return "id не должен быть длиннее 100 символов : (";
  }

  const error = "Должны быть только латинские буквы, цифры и нижнее подчеркивание. ID должен начинаться с буквы, а заканчиваться буквой или цифрой : (";

  // Регулярное выражение:
  // ^[a-zA-Z]          - начинается строго с английской буквы
  // [a-zA-Z0-9_]* - в середине любое кол-во букв, цифр или подчеркиваний
  // [a-zA-Z0-9]$       - заканчивается строго на букву или цифру
  final regExp = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]*[a-zA-Z0-9]$');

  // Дополнительная проверка для строк длиной в 1 символ
  // (так как наше выражение выше рассчитано минимум на 2 символа: начало и конец)
  if (input.length == 1) {
    final result = RegExp(r'^[a-zA-Z]$').hasMatch(input);
    if (!result) return error;
    return null;
  }

  final result = regExp.hasMatch(input);
  if (!result) return error;

  return null;
}

bool isValidRoomName(String roomName) {
  return (roomName.length < 100);
}