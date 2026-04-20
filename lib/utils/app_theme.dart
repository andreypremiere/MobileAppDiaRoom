import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


extension ThemeGetter on BuildContext {
  UICustom get ui => Theme.of(this).extension<UICustom>()!;
}


class AppTheme {
  static const Color primaryColor = Color(0xFF722323);
  static const Color appBarGrey = Color(0xFFB4B4B4);
  static const Color backgroundBeige = Color(0xFFF3F0ED);

  static ThemeData buildTheme(Color seedColor, {bool isDark = false}) {
    return ThemeData(
      useMaterial3: true,
      // brightness: isDark ? Brightness.dark : Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: seedColor,
      ),
      fontFamily: 'SNPro',

      // Настройка AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      textSelectionTheme: TextSelectionThemeData(
        cursorColor: const Color(0xFF101010),
        selectionColor: const Color(0xFF565656).withAlpha(20),
        selectionHandleColor: const Color(0xFF565656),
      ),

      //  Настройка конкретных текстовых стилей
      textTheme: TextTheme(
        // bodyLarge отвечает за текст внутри TextField
        bodyLarge: TextStyle(
          fontFamily: 'SNPro',
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: isDark ? const Color(0xFFE1E1E1) : const Color(0xFF101010),
        ),
        bodyMedium: TextStyle(
          fontFamily: 'SNPro',
          fontSize: 14,
          color: isDark ? const Color(0xFFE1E1E1) : const Color(0xFF101010),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF131313) : const Color(0xFFF3F3F3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF757575) : const Color(0xFFA4A4A4),
          fontSize: 18,
        ),
      ),

      // Настройка Scaffold
      scaffoldBackgroundColor: isDark ? const Color(0xFF2C2A2A) : backgroundBeige,

      extensions: isDark ? [_darkExtension()] : [_lightExtension()],
    );
  }

  static UICustom _lightExtension() => UICustom(
    // Цвета (существующие)
    fontColorPrimary: const Color(0xFF101010),
    fontColorHint: const Color(0xFFA4A4A4),
    fontColorLight: const Color(0xFFF5F5F5),
    // Новые цвета (заполни сам)
    buttonColorSecondary: Colors.white,
    containerColor: Colors.white,
    inputBackgroundColor: const Color(0xFFF3F3F3),
    inputIconColor: const Color(0xFF757575),
    // Размеры (существующие)
    fontSizeHeader: 20,
    fontSizeDefault: 16,
    // Новые размеры (заполни сам)
    fontSizeTitle: 24,
    fontSizeButton: 18,
    fontSizeButtonSecondary: 16,
    // Радиусы и остальное
    borderRadiusBig: 18,
    borderRadiusMedium: 14,
    borderRadiusSmall: 10,
    borderRadiusLittle: 6,
    iconSizePanel: 32,
    iconSizeCategory: 16,
    avatarSizeAppBar: 18,
  );

  static UICustom _darkExtension() => UICustom(
    // Цвета (существующие)
    fontColorPrimary: const Color(0xFFE1E1E1),
    fontColorHint: const Color(0xFF757575),
    fontColorLight: const Color(0xFF757575),
    // Новые цвета (заполни сам)
    buttonColorSecondary: const Color(0xFF000000),
    containerColor: const Color(0xFF050505),
    inputBackgroundColor: const Color(0xFF131313),
    inputIconColor: const Color(0xFFA2A2A2),
    // Размеры (существующие)
    fontSizeHeader: 20,
    fontSizeDefault: 16,
    // Новые размеры (заполни сам)
    fontSizeTitle: 22,
    fontSizeButton: 18,
    fontSizeButtonSecondary: 16,
    // Радиусы и остальное
    borderRadiusBig: 18,
    borderRadiusMedium: 14,
    borderRadiusSmall: 10,
    borderRadiusLittle: 6,
    iconSizePanel: 32,
    iconSizeCategory: 16,
    avatarSizeAppBar: 18,
  );
}

// --- UI CUSTOM EXTENSION ---
@immutable
class UICustom extends ThemeExtension<UICustom> {
  final Color fontColorPrimary;
  final Color fontColorHint;
  final Color fontColorLight;
  final Color buttonColorSecondary;
  final Color containerColor;
  final Color inputBackgroundColor;
  final Color inputIconColor;

  final double fontSizeHeader;
  final double fontSizeTitle;
  final double fontSizeButton;
  final double fontSizeButtonSecondary;
  final double fontSizeDefault;

  final double borderRadiusBig;
  final double borderRadiusMedium;
  final double borderRadiusSmall;
  final double borderRadiusLittle;

  final double iconSizePanel;
  final double iconSizeCategory;

  final double avatarSizeAppBar;

  // Константы начертания
  static const FontWeight textBold = FontWeight.w800;
  static const FontWeight textSemiBold = FontWeight.w700;
  static const FontWeight textMedium = FontWeight.w600;
  static const FontWeight textSemiMedium = FontWeight.w500;
  static const FontWeight textRegular = FontWeight.w400;
  static const FontWeight textSemiRegular = FontWeight.w300;

  const UICustom({
    required this.fontColorPrimary,
    required this.fontColorHint,
    required this.fontColorLight,
    required this.buttonColorSecondary,
    required this.containerColor,
    required this.inputBackgroundColor,
    required this.inputIconColor,
    required this.fontSizeHeader,
    required this.fontSizeTitle,
    required this.fontSizeButton,
    required this.fontSizeButtonSecondary,
    required this.fontSizeDefault,
    required this.borderRadiusBig,
    required this.borderRadiusMedium,
    required this.borderRadiusSmall,
    required this.borderRadiusLittle,
    required this.iconSizePanel,
    required this.iconSizeCategory,
    required this.avatarSizeAppBar,
  });

  @override
  UICustom copyWith({
    Color? fontColorPrimary,
    Color? fontColorHint,
    Color? fontColorLight,
    Color? buttonColorSecondary,
    Color? containerColor,
    Color? inputBackgroundColor,
    Color? inputIconColor,
    double? fontSizeHeader,
    double? fontSizeTitle,
    double? fontSizeButton,
    double? fontSizeButtonSecondary,
    double? fontSizeDefault,
    double? borderRadiusBig,
    double? borderRadiusMedium,
    double? borderRadiusSmall,
    double? borderRadiusLittle,
    double? iconSizePanel,
    double? iconSizeCategory,
    double? avatarSizeAppBar,
  }) {
    return UICustom(
      fontColorPrimary: fontColorPrimary ?? this.fontColorPrimary,
      fontColorHint: fontColorHint ?? this.fontColorHint,
      fontColorLight: fontColorLight ?? this.fontColorLight,
      buttonColorSecondary: buttonColorSecondary ?? this.buttonColorSecondary,
      containerColor: containerColor ?? this.containerColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputIconColor: inputIconColor ?? this.inputIconColor,
      fontSizeHeader: fontSizeHeader ?? this.fontSizeHeader,
      fontSizeTitle: fontSizeTitle ?? this.fontSizeTitle,
      fontSizeButton: fontSizeButton ?? this.fontSizeButton,
      fontSizeButtonSecondary: fontSizeButtonSecondary ?? this.fontSizeButtonSecondary,
      fontSizeDefault: fontSizeDefault ?? this.fontSizeDefault,
      borderRadiusBig: borderRadiusBig ?? this.borderRadiusBig,
      borderRadiusMedium: borderRadiusMedium ?? this.borderRadiusMedium,
      borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
      borderRadiusLittle: borderRadiusLittle ?? this.borderRadiusLittle,
      iconSizePanel: iconSizePanel ?? this.iconSizePanel,
      iconSizeCategory: iconSizeCategory ?? this.iconSizeCategory,
      avatarSizeAppBar: avatarSizeAppBar ?? this.avatarSizeAppBar,
    );
  }

  @override
  UICustom lerp(ThemeExtension<UICustom>? other, double t) {
    if (other is! UICustom) return this;
    return UICustom(
      fontColorPrimary: Color.lerp(fontColorPrimary, other.fontColorPrimary, t)!,
      fontColorHint: Color.lerp(fontColorHint, other.fontColorHint, t)!,
      fontColorLight: Color.lerp(fontColorLight, other.fontColorLight, t)!,
      buttonColorSecondary: Color.lerp(buttonColorSecondary, other.buttonColorSecondary, t)!,
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
      inputBackgroundColor: Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t)!,
      inputIconColor: Color.lerp(inputIconColor, other.inputIconColor, t)!,
      fontSizeHeader: lerpDouble(fontSizeHeader, other.fontSizeHeader, t)!,
      fontSizeTitle: lerpDouble(fontSizeTitle, other.fontSizeTitle, t)!,
      fontSizeButton: lerpDouble(fontSizeButton, other.fontSizeButton, t)!,
      fontSizeButtonSecondary: lerpDouble(fontSizeButtonSecondary, other.fontSizeButtonSecondary, t)!,
      fontSizeDefault: lerpDouble(fontSizeDefault, other.fontSizeDefault, t)!,
      borderRadiusBig: lerpDouble(borderRadiusBig, other.borderRadiusBig, t)!,
      borderRadiusMedium: lerpDouble(borderRadiusMedium, other.borderRadiusMedium, t)!,
      borderRadiusSmall: lerpDouble(borderRadiusSmall, other.borderRadiusSmall, t)!,
      borderRadiusLittle: lerpDouble(borderRadiusLittle, other.borderRadiusLittle, t)!,
      iconSizePanel: lerpDouble(iconSizePanel, other.iconSizePanel, t)!,
      iconSizeCategory: lerpDouble(iconSizeCategory, other.iconSizeCategory, t)!,
      avatarSizeAppBar: lerpDouble(avatarSizeAppBar, other.avatarSizeAppBar, t)!,
    );
  }

  // Вспомогательный метод для интерполяции чисел
  static double? lerpDouble(double? a, double? b, double t) {
    return a == null ? b : (b == null ? a : a + (b - a) * t);
  }
}
