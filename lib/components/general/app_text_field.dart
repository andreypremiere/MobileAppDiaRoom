import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final VoidCallback? onVisibilityToggle;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.onVisibilityToggle,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textAlign: textAlign,
      keyboardType: isPassword ? TextInputType.visiblePassword : keyboardType,
      obscureText: isPassword ? obscureText : false,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        counterText: "",
        fillColor: context.ui.inputBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: context.ui.inputIconColor,
            size: 20,
          ),
          onPressed: onVisibilityToggle,
        )
            : null,
      ),
    );
  }
}