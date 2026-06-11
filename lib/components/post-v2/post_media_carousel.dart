import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../models/enums/file_type.dart';
import '../../components/loading_widget/loader_widget.dart';
import '../../../utils/app_theme.dart';

class PostMediaCarousel extends StatefulWidget {
  final List<dynamic> files;

  const PostMediaCarousel({super.key, required this.files});

  @override
  State<PostMediaCarousel> createState() => _PostMediaCarouselState();
}

class _PostMediaCarouselState extends State<PostMediaCarousel> {
  int _currentPhotoIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.files.isEmpty) return const SizedBox.shrink();

    double ar = 1.0;
    if (widget.files.first.width > 0 && widget.files.first.height > 0) {
      ar = widget.files.first.width / widget.files.first.height;
    }

    final List<String> photoList = widget.files.map((f) => f.urlMedium as String).toList();

    return AspectRatio(
      aspectRatio: ar,
      child: Stack(
        children: [
          Container(
            color: context.ui.fontColorHint.withOpacity(0.1),
            child: CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 1.0,
                aspectRatio: ar,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentPhotoIndex = index;
                  });
                },
              ),
              items: widget.files.asMap().entries.map((entry) {
                final int index = entry.key;
                final file = entry.value;

                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        context.push(
                          '/full_image_screen',
                          extra: {
                            'urls': photoList,
                            'index': index,
                            'type': FileType.network,
                          },
                        );
                      },
                      child: CachedNetworkImage(
                        imageUrl: file.urlSmall,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        placeholder: (context, url) => const Center(
                          child: DiaRoomLoader(),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.error_outline,
                          size: 40,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          if (widget.files.length > 1)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${widget.files.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}