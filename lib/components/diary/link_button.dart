import 'package:flutter/material.dart';
import 'package:dia_room/utils/app_theme.dart';

class CustomLinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onClose;

  const CustomLinkButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onTap ?? () {},
          style: OutlinedButton.styleFrom(
            foregroundColor: context.ui.primaryColor,
            side: BorderSide(
              color: context.ui.primaryColor,
              width: 1.5,
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: () {

                    onClose!();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: context.ui.primaryColor.withAlpha(70),
                    ),
                  ),
                ),
            ],
          ),
        ),
    );
  }
}