import 'package:flutter/material.dart';

class KeyboardDismissible extends StatelessWidget {
  final Widget child;

  const KeyboardDismissible({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final focus = FocusScope.of(context);
        if (!focus.hasPrimaryFocus) focus.unfocus();
      },
      child: child,
    );
  }
}