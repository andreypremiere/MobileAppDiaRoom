import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PhotoTileItem extends StatelessWidget {
  final String path;
  final List<String> allPaths;
  final int index;
  final bool isLocal;
  final VoidCallback? onTap;

  const PhotoTileItem({
    super.key,
    required this.path,
    required this.allPaths,
    required this.index,
    required this.isLocal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: isLocal
          ? Image.file(
        File(path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Обработка ошибки, если локальный файл удален
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      )
          : CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => Container(
          color: Colors.white.withAlpha(10),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorWidget(),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white.withAlpha(10),
      child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
    );
  }
}