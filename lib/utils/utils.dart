// Функция для создания полного пути из базового url и postfix
import 'package:flutter/material.dart';

String createFullPathAvatar(String prefix, String postfix) {
  return "$prefix/$postfix";
}

FontWeight getFontWeight(int value) {
  switch (value) {
    case 400: return FontWeight.w400;
    case 600: return FontWeight.w600;
    case 800: return FontWeight.w800;
    default: return FontWeight.w400;
  }
}