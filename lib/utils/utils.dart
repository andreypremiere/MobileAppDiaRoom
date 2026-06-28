import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../configuration/urls.dart';
import '../contracts/account-microservice/requests/check_version_request.dart';

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
    return "$hours:${twoDigits(minutes)}:${twoDigits(seconds)}";
  } else {
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
  print('\x1B[31;1m$text\x1B[0m');
}

String? isValidRoomId(String input) {
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
  return (roomName.isNotEmpty && roomName.length < 100);
}

String formatSmartDate(DateTime date) {
  final localDate = date.toLocal();

  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final dateToCheck = DateTime(localDate.year, localDate.month, localDate.day);

  final String timePart = DateFormat('HH:mm').format(localDate);

  if (dateToCheck == today) {
    return timePart;
  } else if (dateToCheck == yesterday) {
    return "Вчера в $timePart";
  } else {
    // Для старых дат выводим день и время
    return "$timePart · ${DateFormat('dd.MM.yy').format(localDate)}";
  }
}

Future<CheckVersionRequest> getAppVersionRequest() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  return CheckVersionRequest(
    version: packageInfo.version,
    numberBuild: packageInfo.buildNumber,
  );
}