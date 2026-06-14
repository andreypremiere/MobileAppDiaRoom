import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:dia_room/models/enums/categories.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

class BasePostCard extends StatelessWidget {
  final String title;
  final String? previewUrl;
  final Categories? category;
  final VoidCallback onTap;
  final Widget bottomPanel;
  final Widget? topAction;

  const BasePostCard({
    super.key,
    required this.title,
    required this.previewUrl,
    required this.category,
    required this.onTap,
    required this.bottomPanel,
    this.topAction
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Material(
        color: context.ui.containerColor,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  children: [
                    _buildImage(context),
                    // category != null ? _buildCategoryBadge(context) : SizedBox.shrink(),
                    if (topAction != null)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: topAction!,
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: context.ui.fontColorPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: bottomPanel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вспомогательные методы для чистоты кода
  Widget _buildImage(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: previewUrl ?? '',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => Center(child: DiaRoomLoader()),
      errorWidget: (context, url, error) {
        return Container(
          color: const Color(0xFFE0E0E0),
          child: const Icon(Icons.broken_image_outlined, size: 40, color: Color(0xFF888888)),
        );
      },
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Positioned(
      left: 8, bottom: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: context.ui.containerColor.withAlpha(85),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          category?.label ?? "Не выбрана",
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: context.ui.fontColorPrimary),
        ),
      ),
    );
  }
}

