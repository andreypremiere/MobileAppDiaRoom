import 'package:flutter/material.dart';
import '../../../utils/app_theme.dart';

class PostDescription extends StatefulWidget {
  final String? description;

  const PostDescription({super.key, this.description});

  @override
  State<PostDescription> createState() => _PostDescriptionState();
}

class _PostDescriptionState extends State<PostDescription> {
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final description = widget.description;
    if (description == null || description.isEmpty) return const SizedBox.shrink();

    final TextStyle textStyle = TextStyle(
      color: context.ui.fontColorPrimary,
      fontWeight: FontWeight.w400,
      fontSize: 15,
      height: 1.4,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textPainter = TextPainter(
            text: TextSpan(text: description, style: textStyle),
            textDirection: TextDirection.ltr,
            maxLines: 2,
          );

          textPainter.layout(maxWidth: constraints.maxWidth);
          final bool isTooLong = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                maxLines: _isDescriptionExpanded ? null : 2,
                overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                text: TextSpan(
                  style: textStyle,
                  children: [TextSpan(text: description)],
                ),
              ),
              if (isTooLong)
                InkWell(
                  onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      _isDescriptionExpanded ? "Скрыть" : "Показать полностью",
                      style: TextStyle(
                        color: context.ui.fontColorHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}