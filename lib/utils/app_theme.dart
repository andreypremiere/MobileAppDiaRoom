import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


extension ThemeGetter on BuildContext {
  UICustom get ui => Theme.of(this).extension<UICustom>()!;
}


class AppTheme {
  static const Color primaryColor = Color(0xFF722323);
  static const Color appBarGrey = Color(0xFFB4B4B4);
  static const Color backgroundBeige = Color(0xFFF6F5F4);

  static ThemeData buildTheme(Color seedColor, {bool isDark = false}) {
    final toolbarBackgroundColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFFFFFF);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: seedColor,
        surface: toolbarBackgroundColor,
      ),
      fontFamily: 'SNPro',

      // Настройка AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStateProperty.all(toolbarBackgroundColor),
          // Здесь же можно настроить скругление углов всего тулбара, если захочешь:
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),

      // 2. Бэкап для выпадающих системных списков (копировать/вставить на старых инпутах)
      popupMenuTheme: PopupMenuThemeData(
        color: toolbarBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),

      // Исторические параметры для старых виджетов, пусть будут для надежности
      cardColor: toolbarBackgroundColor,
      canvasColor: toolbarBackgroundColor,

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
    primaryColor: const Color(0xFF722323),
    // Цвета (существующие)
    fontColorPrimary: const Color(0xFF101010),
    iconColorPrimary: const Color(0xFF101010),
    fontColorHint: const Color(0xFFA4A4A4),
    fontColorLight: const Color(0xFFF5F5F5),
    sectionButtonColor: const Color(0xFF722323),
    // Новые цвета (заполни сам)
    buttonColorSecondary: Colors.white,
    containerColor: Colors.white,
    inputBackgroundColor: const Color(0xFFF3F3F3),
    inputIconColor: const Color(0xFF757575),
    // Размеры (существующие)
    fontSizeHeader: 20,
    fontSizeDefault: 16,
    radiusButtonStandard: 12,
    fontSizeTitle: 24,
    fontSizeButton: 18,
    fontSizeButtonSecondary: 16,
    // Радиусы и остальное
    borderRadiusBig: 18,
    borderRadiusMedium: 14,
    borderRadiusSmall: 10,
    borderRadiusLittle: 6,
    iconSizePanel: 32,
    iconSizeBottomPanel: 32,
    iconSizeCategory: 16,
    avatarSizeAppBar: 18,
    appBarColor: const Color(0xFFB4B4B4),
    viewingPostColor: const Color(0xFFF5F5F5),
    elementsPhotoViewerColor: const Color(0xFFDADADA),
    elementsVideoPlayerColor: const Color(0xFFDADADA),
    backgroundViewer: Colors.black,
    toolbarContainerColor: const Color(0xFF575757),
    toolbarItemColor: const Color(0xFFBBBBBB),
  );

  static UICustom _darkExtension() => UICustom(
    primaryColor: const Color(0xFF9B6D6D),
    // Цвета (существующие)
    fontColorPrimary: const Color(0xFFE1E1E1),
    iconColorPrimary: const Color(0xFFE1E1E1),
    fontColorHint: const Color(0xFF757575),
    fontColorLight: const Color(0xFF757575),
    // Новые цвета (заполни сам)
    buttonColorSecondary: const Color(0xFF000000),
    sectionButtonColor: const Color(0xFF9B6D6D),
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
    radiusButtonStandard: 12,
    // Радиусы и остальное
    borderRadiusBig: 18,
    borderRadiusMedium: 14,
    borderRadiusSmall: 10,
    borderRadiusLittle: 6,
    iconSizePanel: 32,
    iconSizeBottomPanel: 32,
    iconSizeCategory: 16,
    avatarSizeAppBar: 18,
    appBarColor: const Color(0xFF595959),
    viewingPostColor: const Color(0xFF1C1C1C),
    elementsPhotoViewerColor: const Color(0xFFDADADA),
    elementsVideoPlayerColor: const Color(0xFFDADADA),
    backgroundViewer: Colors.black,
    toolbarContainerColor: const Color(0xFF575757),
    toolbarItemColor: const Color(0xFF777777),
  );
}

@immutable
class UICustom extends ThemeExtension<UICustom> {
  // Цвета
  final Color primaryColor;
  final Color fontColorPrimary;
  final Color fontColorHint;
  final Color fontColorLight;
  final Color buttonColorSecondary;
  final Color containerColor;
  final Color inputBackgroundColor;
  final Color inputIconColor;
  final Color sectionButtonColor;
  final Color appBarColor;
  final Color viewingPostColor;
  final Color iconColorPrimary;

  // Размеры и шрифты
  final double fontSizeHeader;
  final double fontSizeTitle;
  final double fontSizeButton;
  final double fontSizeButtonSecondary;
  final double fontSizeDefault;

  // Радиусы
  final double borderRadiusBig;
  final double borderRadiusMedium;
  final double borderRadiusSmall;
  final double borderRadiusLittle;

  final double radiusButtonStandard;

  // Иконки и аватары
  final double iconSizePanel;
  final double iconSizeCategory;
  final double iconSizeBottomPanel;
  final double avatarSizeAppBar;


  final Color elementsVideoPlayerColor;
  final Color elementsPhotoViewerColor;
  final Color backgroundViewer;
  final Color toolbarContainerColor;
  final Color toolbarItemColor;

  // Константы начертания
  static const FontWeight textBold = FontWeight.w800;
  static const FontWeight textSemiBold = FontWeight.w700;
  static const FontWeight textMedium = FontWeight.w600;
  static const FontWeight textSemiMedium = FontWeight.w500;
  static const FontWeight textRegular = FontWeight.w400;
  static const FontWeight textSemiRegular = FontWeight.w300;

  const UICustom({
    required this.primaryColor,
    required this.iconColorPrimary,
    required this.fontColorPrimary,
    required this.fontColorHint,
    required this.fontColorLight,
    required this.buttonColorSecondary,
    required this.containerColor,
    required this.inputBackgroundColor,
    required this.inputIconColor,
    required this.sectionButtonColor,
    required this.appBarColor,
    required this.viewingPostColor,
    required this.fontSizeHeader,
    required this.radiusButtonStandard,
    required this.fontSizeTitle,
    required this.fontSizeButton,
    required this.fontSizeButtonSecondary,
    required this.fontSizeDefault,
    required this.borderRadiusBig,
    required this.borderRadiusMedium,
    required this.borderRadiusSmall,
    required this.borderRadiusLittle,
    required this.iconSizePanel,
    required this.iconSizeBottomPanel,
    required this.iconSizeCategory,
    required this.avatarSizeAppBar,
    required this.elementsVideoPlayerColor,
    required this.elementsPhotoViewerColor,
    required this.backgroundViewer,
    required this.toolbarContainerColor,
    required this.toolbarItemColor,
  });

  @override
  UICustom copyWith({
    Color? primaryColor,
    Color? fontColorPrimary,
    Color? iconColorPrimary,
    Color? fontColorHint,
    Color? fontColorLight,
    Color? buttonColorSecondary,
    Color? containerColor,
    Color? inputBackgroundColor,
    Color? inputIconColor,
    Color? sectionButtonColor,
    Color? appBarColor,
    Color? viewingPostColor,
    double? fontSizeHeader,
    double? fontSizeTitle,
    double? fontSizeButton,
    double? fontSizeButtonSecondary,
    double? fontSizeDefault,
    double? radiusButtonStandard,
    double? borderRadiusBig,
    double? borderRadiusMedium,
    double? borderRadiusSmall,
    double? borderRadiusLittle,
    double? iconSizePanel,
    double? iconSizeBottomPanel,
    double? iconSizeCategory,
    double? avatarSizeAppBar,
    Color? elementsVideoPlayerColor,
    Color? elementsPhotoViewerColor,
    Color? backgroundViewer,
    Color? toolbarContainerColor,
    Color? toolbarItemColor,
  }) {
    return UICustom(
      primaryColor: primaryColor ?? this.primaryColor,
      fontColorPrimary: fontColorPrimary ?? this.fontColorPrimary,
      iconColorPrimary: iconColorPrimary ?? this.iconColorPrimary,
      fontColorHint: fontColorHint ?? this.fontColorHint,
      fontColorLight: fontColorLight ?? this.fontColorLight,
      buttonColorSecondary: buttonColorSecondary ?? this.buttonColorSecondary,
      containerColor: containerColor ?? this.containerColor,
      inputBackgroundColor: inputBackgroundColor ?? this.inputBackgroundColor,
      inputIconColor: inputIconColor ?? this.inputIconColor,
      sectionButtonColor: sectionButtonColor ?? this.sectionButtonColor,
      appBarColor: appBarColor ?? this.appBarColor,
      viewingPostColor: viewingPostColor ?? this.viewingPostColor,
      fontSizeHeader: fontSizeHeader ?? this.fontSizeHeader,
      fontSizeTitle: fontSizeTitle ?? this.fontSizeTitle,
      fontSizeButton: fontSizeButton ?? this.fontSizeButton,
      fontSizeButtonSecondary: fontSizeButtonSecondary ?? this.fontSizeButtonSecondary,
      fontSizeDefault: fontSizeDefault ?? this.fontSizeDefault,
      borderRadiusBig: borderRadiusBig ?? this.borderRadiusBig,
      radiusButtonStandard: radiusButtonStandard ?? this.radiusButtonStandard,
      borderRadiusMedium: borderRadiusMedium ?? this.borderRadiusMedium,
      borderRadiusSmall: borderRadiusSmall ?? this.borderRadiusSmall,
      borderRadiusLittle: borderRadiusLittle ?? this.borderRadiusLittle,
      iconSizePanel: iconSizePanel ?? this.iconSizePanel,
      iconSizeBottomPanel: iconSizeBottomPanel ?? this.iconSizeBottomPanel,
      iconSizeCategory: iconSizeCategory ?? this.iconSizeCategory,
      avatarSizeAppBar: avatarSizeAppBar ?? this.avatarSizeAppBar,
      elementsVideoPlayerColor: elementsVideoPlayerColor ?? this.elementsVideoPlayerColor,
      elementsPhotoViewerColor: elementsPhotoViewerColor ?? this.elementsPhotoViewerColor,
      backgroundViewer: backgroundViewer ?? this.backgroundViewer,
      toolbarContainerColor: toolbarContainerColor ?? this.toolbarContainerColor,
      toolbarItemColor: toolbarItemColor ?? this.toolbarItemColor,
    );
  }

  @override
  UICustom lerp(ThemeExtension<UICustom>? other, double t) {
    if (other is! UICustom) return this;
    return UICustom(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t)!,
      iconColorPrimary: Color.lerp(iconColorPrimary, other.iconColorPrimary, t)!,
      fontColorPrimary: Color.lerp(fontColorPrimary, other.fontColorPrimary, t)!,
      fontColorHint: Color.lerp(fontColorHint, other.fontColorHint, t)!,
      fontColorLight: Color.lerp(fontColorLight, other.fontColorLight, t)!,
      buttonColorSecondary: Color.lerp(buttonColorSecondary, other.buttonColorSecondary, t)!,
      containerColor: Color.lerp(containerColor, other.containerColor, t)!,
      inputBackgroundColor: Color.lerp(inputBackgroundColor, other.inputBackgroundColor, t)!,
      sectionButtonColor: Color.lerp(sectionButtonColor, other.sectionButtonColor, t)!,
      inputIconColor: Color.lerp(inputIconColor, other.inputIconColor, t)!,
      appBarColor: Color.lerp(appBarColor, other.appBarColor, t)!,
      viewingPostColor: Color.lerp(viewingPostColor, other.viewingPostColor, t)!,
      fontSizeHeader: lerpDouble(fontSizeHeader, other.fontSizeHeader, t)!,
      fontSizeTitle: lerpDouble(fontSizeTitle, other.fontSizeTitle, t)!,
      fontSizeButton: lerpDouble(fontSizeButton, other.fontSizeButton, t)!,
      fontSizeButtonSecondary: lerpDouble(fontSizeButtonSecondary, other.fontSizeButtonSecondary, t)!,
      fontSizeDefault: lerpDouble(fontSizeDefault, other.fontSizeDefault, t)!,
      borderRadiusBig: lerpDouble(borderRadiusBig, other.borderRadiusBig, t)!,
      borderRadiusMedium: lerpDouble(borderRadiusMedium, other.borderRadiusMedium, t)!,
      borderRadiusSmall: lerpDouble(borderRadiusSmall, other.borderRadiusSmall, t)!,
      radiusButtonStandard: lerpDouble(radiusButtonStandard, other.radiusButtonStandard, t)!,
      borderRadiusLittle: lerpDouble(borderRadiusLittle, other.borderRadiusLittle, t)!,
      iconSizePanel: lerpDouble(iconSizePanel, other.iconSizePanel, t)!,
      iconSizeBottomPanel: lerpDouble(iconSizeBottomPanel, other.iconSizeBottomPanel, t)!,
      iconSizeCategory: lerpDouble(iconSizeCategory, other.iconSizeCategory, t)!,
      avatarSizeAppBar: lerpDouble(avatarSizeAppBar, other.avatarSizeAppBar, t)!,
      elementsVideoPlayerColor: Color.lerp(elementsVideoPlayerColor, other.elementsVideoPlayerColor, t)!,
      elementsPhotoViewerColor: Color.lerp(elementsPhotoViewerColor, other.elementsPhotoViewerColor, t)!,
      backgroundViewer: Color.lerp(backgroundViewer, other.backgroundViewer, t)!,
      toolbarContainerColor: Color.lerp(toolbarContainerColor, other.toolbarContainerColor, t)!,
      toolbarItemColor: Color.lerp(toolbarItemColor, other.toolbarItemColor, t)!,
    );
  }

  static double? lerpDouble(double? a, double? b, double t) {
    return a == null ? b : (b == null ? a : a + (b - a) * t);
  }
}
