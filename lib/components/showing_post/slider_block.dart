import 'package:flutter/material.dart';
import 'photo_tile_item.dart';

class PhotoSlider extends StatefulWidget {
  final List<String> urls;
  final bool isLocal;
  final Function(int index) onTap;

  const PhotoSlider({
    super.key,
    required this.urls,
    required this.onTap,
    this.isLocal = false,
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
            return PhotoTileItem(
              path: widget.urls[index],
              allPaths: widget.urls,
              index: index,
              isLocal: widget.isLocal,
              onTap: () => widget.onTap(index),
            );
          },
        ),

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
}