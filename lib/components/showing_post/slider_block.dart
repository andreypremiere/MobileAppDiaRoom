import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class PhotoSlider extends StatefulWidget {
  final List<String> urls;
  final Function(int index) onTap; // Добавляем callback

  const PhotoSlider({
    super.key,
    required this.urls,
    required this.onTap, // Обязательный параметр
  });

  @override
  State<PhotoSlider> createState() => _PhotoSliderState();
}

class _PhotoSliderState extends State<PhotoSlider> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.urls.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            // Оборачиваем в GestureDetector
            return GestureDetector(
              onTap: () => widget.onTap(index), // Вызываем callback родителя
              child: _buildNetworkImage(widget.urls[index]),
            );
          },
        ),

        // ... (твой код индикатора 1/5 без изменений)
        if (widget.urls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPage + 1}/${widget.urls.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'SNPro',
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
    );
  }
}