import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dia_room/components/info_dialog_component.dart';
import 'package:dia_room/services/diary/diary_utils.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../../components/general/app_back_button.dart';
import '../../configuration/constants.dart';

class VideoRecordResult {
  final String path;
  final Duration duration;
  final int sizeInBytes;

  VideoRecordResult({required this.path, required this.duration, required this.sizeInBytes});
}

class VideoRecordScreen extends StatefulWidget {
  const VideoRecordScreen({super.key});

  @override
  State<VideoRecordScreen> createState() => _VideoRecordScreenState();
}

class _VideoRecordScreenState extends State<VideoRecordScreen> with WidgetsBindingObserver {
  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  VideoPlayerController? _videoPlayerController;

  bool _isRecording = false;
  bool _isPreviewMode = false;
  bool _isPaused = false;
  int _cameraIndex = 1;
  String? _videoPath;

  Timer? _timer;
  int _recordDuration = 0;

  final ValueNotifier<Duration> _videoPosition = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _onNewCameraSelected(cameraController.description);
    }
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras.isNotEmpty) {
      _onNewCameraSelected(_cameras[_cameraIndex % _cameras.length]);
    }
  }

  Future<void> _onNewCameraSelected(CameraDescription description) async {
    if (_controller != null) {
      final oldController = _controller;
      _controller = null;
      await oldController!.dispose();
    }

    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.low,
      fps: 24,
      videoBitrate: 1000000,
      enableAudio: true,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      if (!mounted) return;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось инициализировать камеру. Пожалуйста, обратитесь в поддержку.");
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller?.dispose();
    _videoPlayerController?.dispose();
    _videoPosition.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.startVideoRecording();
      if (mounted) {
        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
        });
      } else {
        return;
      }
      _startTimer();
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось начать запись. Пожалуйста, обратитесь в поддержку.");
      }
    }
  }

  Future<void> _pauseRecording() async {
    if (_controller == null || !_controller!.value.isRecordingVideo) return;
    try {
      await _controller!.pauseVideoRecording();
      _stopTimer();
      if (mounted) {
        setState(() => _isPaused = true);
      }
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось приостановить запись. Пожалуйста, обратитесь в поддержку.");
      }
    }
  }

  Future<void> _resumeRecording() async {
    if (_controller == null || !_controller!.value.isRecordingPaused) return;
    try {
      await _controller!.resumeVideoRecording();
      _startTimer();
      if (mounted) {
        setState(() => _isPaused = false);
      }
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось возобновить запись. Пожалуйста, обратитесь в поддержку.");
      }
    }
  }

  Future<void> _stopRecording() async {
    _stopTimer();
    try {
      final file = await _controller!.stopVideoRecording();

      await _controller!.pausePreview();
      if (mounted) {
        setState(() {
          _isRecording = false;
          _isPaused = false;
          _videoPath = file.path;
          _isPreviewMode = true;
        });
      } else {
        return;
      }
      _initVideoPlayer(File(file.path));
    } catch (e) {
      if (mounted) {
        await AppInfoDialog.show(context, "Не удалось остановить запись. Пожалуйста, обратитесь в поддержку.");
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) {
        setState(() {
          _recordDuration++;
        });
      } else {
        return;
      }

      if (_recordDuration >= limitRecordVideoNoteInDiary) {
        _stopRecording();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  Future<void> _initVideoPlayer(File file) async {
    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();

    _videoPlayerController!.addListener(() {
      _videoPosition.value = _videoPlayerController!.value.position;
      if (_videoPlayerController!.value.position >= _videoPlayerController!.value.duration) {
        _videoPlayerController!.seekTo(Duration.zero);
        _videoPlayerController!.pause();
        if (mounted) {
          setState(() {});
        } else {
          return;
        }
      }
    });

    await _videoPlayerController!.play();
    if (mounted) {
      setState(() {});
    }
  }

  void _reset() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    DiaryUtils.deleteFile(_videoPath);
    if (mounted) {
      setState(() {
        _isPreviewMode = false;
        _videoPath = null;
        _recordDuration = 0;
      });
    } else {
      return;
    }

    if (_controller != null) {
      _onNewCameraSelected(_controller!.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        leading: AppBackButton(onPressed: () {context.pop(); DiaryUtils.deleteFile(_videoPath);},),
        title: Text('Видеосообщение'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: size,
          child:
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[900],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildMediaView(),
            ),
          )),

          if (_isPreviewMode)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - size) / 2),
              child: _buildPlayerControls(),
            ),

          if (!_isPreviewMode) ...[
            const SizedBox(height: 20),
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(color: context.ui.fontColorPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _isPreviewMode
                  ? _buildIconBtn(Icons.delete, Colors.red, _reset)
                  : _buildIconBtn(Icons.flip_camera_ios, context.ui.fontColorHint, _toggleCamera),

              _buildMainButton(),

              if (_isPreviewMode)
                _buildActionButton(Icons.send_rounded, context.ui.primaryColor, () async {
                  final file = File(_videoPath!);

                  final int fileSize = await file.length();

                  if (context.mounted) {
                    Navigator.pop(
                      context,
                      VideoRecordResult(
                        path: _videoPath!,
                        duration: Duration(seconds: _recordDuration),
                        sizeInBytes: fileSize,
                      ),
                    );
                  }
                })
              else if (_isRecording)
                _buildActionButton(
                  _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  Colors.orange,
                  _isPaused ? _resumeRecording : _pauseRecording,
                )
              else
                const SizedBox(width: 50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaView() {
    if (_isPreviewMode && _videoPlayerController != null) {
      if (!_videoPlayerController!.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }

      final videoSize = _videoPlayerController!.value.size;
      if (videoSize.width == 0 || videoSize.height == 0) {
        return Container(color: Colors.black);
      }

      final isFront = _cameras[_cameraIndex % _cameras.length].lensDirection == CameraLensDirection.front;

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoSize.width,
            height: videoSize.height,
            child: Transform.scale(
              scaleX: isFront ? -1 : 1,
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
        ),
      );
    }

    if (!_isPreviewMode && _controller != null && _controller!.value.isInitialized) {
      final previewSize = _controller!.value.previewSize;
      if (previewSize == null) return const Center(child: CircularProgressIndicator());

      final isFront = _controller!.description.lensDirection == CameraLensDirection.front;

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: Transform.scale(
              scaleX: isFront ? 1 : 1,
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      );
    }

    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildPlayerControls() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            IconButton(
              onPressed: () {
                _videoPlayerController!.value.isPlaying
                    ? _videoPlayerController!.pause()
                    : _videoPlayerController!.play();
                if (mounted) {
                  setState(() {});
                }
              },
              icon: Icon(
                _videoPlayerController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 40,
                color: context.ui.primaryColor,
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _videoPosition,
                builder: (context, Duration pos, child) {
                  final double durationMs = _videoPlayerController!.value.duration.inMilliseconds.toDouble();
                  final double positionMs = pos.inMilliseconds.toDouble();

                  final double maxSafe = durationMs > 0 ? durationMs : (positionMs > 0 ? positionMs : 1.0);
                  final double valueSafe = positionMs.clamp(0.0, maxSafe);

                  return SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                      activeTrackColor: context.ui.primaryColor,
                      inactiveTrackColor: context.ui.primaryColor.withAlpha(50),
                      thumbColor: context.ui.primaryColor,
                    ),
                    child: Slider(
                      value: valueSafe,
                      max: maxSafe,
                      onChanged: (v) {
                        _videoPlayerController!.seekTo(Duration(milliseconds: v.toInt()));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 28),
      ),
    );
  }

  Widget _buildMainButton() {
    if (_isPreviewMode) return const SizedBox(width: 80);
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: _isRecording ? Colors.red.withOpacity(0.2) : context.ui.primaryColor.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: _isRecording ? 30 : 60,
            height: _isRecording ? 30 : 60,
            decoration: BoxDecoration(
              color: _isRecording ? Colors.red : context.ui.primaryColor,
              borderRadius: BorderRadius.circular(_isRecording ? 5 : 30),
            ),
            child: Icon(
              _isRecording ? Icons.stop : Icons.videocam_rounded,
              color: Colors.white,
              size: _isRecording ? 20 : 30,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleCamera() async {
    if (_isRecording) return;
    _cameraIndex++;
    _onNewCameraSelected(_cameras[_cameraIndex % _cameras.length]);
  }

  Widget _buildIconBtn(IconData icon, Color color, VoidCallback onTap) {
    return IconButton(icon: Icon(icon, color: color, size: 30), onPressed: onTap);
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return "$mins:$secs";
  }
}