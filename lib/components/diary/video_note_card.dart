import 'dart:io';

import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../contracts/diary/response/getting_messages.dart';

class VideoMessageBubble extends StatefulWidget {
  final MessagePresentation message;

  const VideoMessageBubble({super.key, required this.message});

  @override
  State<VideoMessageBubble> createState() => _VideoMessageBubbleState();
}

class _VideoMessageBubbleState extends State<VideoMessageBubble> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    if (widget.message.attachments.isNotEmpty) {
      final att = widget.message.attachments.first;
      _duration = Duration(milliseconds: att.duration ?? 0);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_controller == null) {
      final url = widget.message.attachments.first.s3Key;

      try {

        final File videoFile = await DefaultCacheManager().getSingleFile(url);

        _controller = VideoPlayerController.file(videoFile);

        await _controller!.initialize();
        _controller!.addListener(() {
          if (mounted) {
            setState(() {
              _position = _controller!.value.position;
              _isPlaying = _controller!.value.isPlaying;
            });
          }
        });
        setState(() => _isInitialized = true);
      } catch (e) {
        return;
      }
    }

    // Дальше логика управления воспроизведением без изменений
    if (_isPlaying) {
      await _controller!.pause();
    } else {
      if (_position >= _duration) {
        await _controller!.seekTo(Duration.zero);
      }
      await _controller!.play();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.7; // 70% ширины
    final previewUrl = widget.message.attachments.first.previewS3Key;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Всегда слева
        children: [
          // 1. Квадратик видео (70% ширины)
          Container(
            width: maxWidth,
            height: maxWidth, // Квадрат
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black12,
            ),
            clipBehavior: Clip.antiAlias,
            child: GestureDetector(
              onTap: _togglePlay,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Показываем видео, если инициализировано, иначе превью
                  _isInitialized
                      ? SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _controller!.value.size.width,
                        height: _controller!.value.size.height,
                        child: VideoPlayer(_controller!),
                      ),
                    ),
                  )
                      : (previewUrl != null
                      ? CachedNetworkImage(
                    imageUrl: previewUrl,
                    fit: BoxFit.cover,
                    width: maxWidth,
                    height: maxWidth,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.videocam, color: Colors.white54),
                  )
                      : Container(color: Colors.black87)),

                  // Иконка Play поверх превью (если не играет)
                  if (!_isPlaying)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. Блок управления (как в аудио, но под видео)
          SizedBox(
            width: maxWidth,
            child: Row(
              children: [
                // Кнопка Play/Pause
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.ui.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: context.ui.primaryColor,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Слайдер и время
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatDuration(_isPlaying || _position != Duration.zero ? _position : _duration),
                        style: TextStyle(
                          fontSize: 12,
                          color: context.ui.fontColorPrimary.withOpacity(0.7),
                        ),
                      ),
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                          activeTrackColor: context.ui.primaryColor,
                          inactiveTrackColor: context.ui.primaryColor.withOpacity(0.2),
                          thumbColor: context.ui.primaryColor,
                        ),
                        child: Slider(
                          min: 0,
                          max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                          value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                          onChanged: (value) async {
                            if (_isInitialized) {
                              await _controller!.seekTo(Duration(milliseconds: value.toInt()));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}