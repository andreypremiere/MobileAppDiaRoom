import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class AuthFormContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double borderRadius;

  const AuthFormContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderRadius = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: padding,
      decoration: BoxDecoration(
        color: context.ui.containerColor, // или Theme
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}