import 'dart:io';

import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import '../../models/enums/file_type.dart';

class FullScreenVideoScreen extends StatefulWidget {
  final String videoUrl;
  final FileType type;

  const FullScreenVideoScreen({
    super.key,
    required this.videoUrl,
    this.type = FileType.network,
  });

  @override
  State<FullScreenVideoScreen> createState() => _FullScreenVideoScreenState();
}

class _FullScreenVideoScreenState extends State<FullScreenVideoScreen> {
  late VideoPlayerController _controller;
  bool _isControlsVisible = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initController();

    _controller.addListener(() {
      setState(() {});
    });
  }

  void _initController() {
    if (widget.type == FileType.local) {
      _controller = VideoPlayerController.file(File(widget.videoUrl));
    } else {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
    }

    _controller
        .initialize()
        .then((_) {
          if (mounted) {
            setState(() {});
            _controller.play();
          }
        })
        .catchError((error) {
          if (mounted) {
            setState(() {
              _errorMessage = "Не удалось загрузить видео";
            });
          }
        });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ui.backgroundViewer,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: _errorMessage != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: context.ui.elementsVideoPlayerColor,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: context.ui.elementsVideoPlayerColor,
                          ),
                        ),
                      ],
                    )
                  : _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    )
                  : CircularProgressIndicator(
                      color: context.ui.elementsVideoPlayerColor,
                    ),
            ),

            if (_isControlsVisible) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black87, Colors.transparent],
                    ),
                  ),
                ),
              ),

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

              // Затемнение снизу для контроллеров
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: 20,
                    left: 16,
                    right: 16,
                    top: 40,
                  ),
                  decoration: BoxDecoration(color: context.ui.backgroundViewer),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Прогресс бар
                      VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true, // Позволяет перематывать свайпом
                        colors: const VideoProgressColors(
                          playedColor: Color(0xFFFF5E5E),
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.white12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Кнопка Play/Pause и таймер
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              _controller.value.isPlaying
                                  ? _controller.pause()
                                  : _controller.play();
                            },
                            child: Icon(
                              _controller.value.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: context.ui.elementsVideoPlayerColor,
                              size: 42,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                            style: TextStyle(
                              color: context.ui.elementsVideoPlayerColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
