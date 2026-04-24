import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/enums/file_type.dart';

class FullImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final FileType type; // Добавляем тип контента

  const FullImageScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.type = FileType.network,
  });

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Свайпер изображений
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 1.0, // Лучше начинать с 1.0, чтобы не было "болтанки"
                  maxScale: 4.0,
                  child: _buildImage(widget.imageUrls[index]),
                ),
              );
            },
          ),

          // 2. Кнопка "Назад"
          Positioned(
            top: MediaQuery.of(context).padding.top,
            left: 10,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                Icons.arrow_back_rounded,
                size: context.ui.iconSizePanel,
              ),
              color: context.ui.elementsVideoPlayerColor,
            ),
          ),

          // 3. Индикатор
          if (widget.imageUrls.length > 1)
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imageUrls.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Универсальный загрузчик картинки
  Widget _buildImage(String path) {
    if (widget.type == FileType.local) {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    } else {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.white24, strokeWidth: 2),
        ),
        errorWidget: (context, url, error) => _buildError(),
      );
    }
  }

  Widget _buildError() {
    return const Center(
      child: Icon(Icons.broken_image_outlined, color: Colors.white24, size: 64),
    );
  }
}