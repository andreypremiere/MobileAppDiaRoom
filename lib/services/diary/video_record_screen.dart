import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../components/general/app_back_button.dart';

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
  int _cameraIndex = 1;
  String? _videoPath;

  Timer? _timer;
  int _recordDuration = 0;

  // Для управления плеером
  ValueNotifier<Duration> _videoPosition = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // Если приложение свернуто - освобождаем камеру
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
    // 1. Сначала полностью останавливаем и удаляем старый контроллер
    if (_controller != null) {
      final oldController = _controller;
      _controller = null; // Обнуляем ссылку сразу, чтобы UI не пытался к нему обращаться
      await oldController!.dispose();
    }

    // 2. Создаем новый контроллер
    final CameraController cameraController = CameraController(
      description,
      ResolutionPreset.high,
      fps: 30,
      videoBitrate: 2500000,
      enableAudio: true,
    );

    _controller = cameraController;

    try {
      await cameraController.initialize();
      // 3. Если во время инициализации пользователь уже ушел с экрана — закрываем камеру
      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint("Ошибка камеры: $e");
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

  // --- Логика записи ---

  Future<void> _startRecording() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      await _controller!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (t) => setState(() => _recordDuration++));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    try {
      final file = await _controller!.stopVideoRecording();
      await _controller!.pausePreview();
      setState(() {
        _isRecording = false;
        _videoPath = file.path;
        _isPreviewMode = true;
      });
      _initVideoPlayer(File(file.path));
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // --- Управление плеером ---

  Future<void> _initVideoPlayer(File file) async {
    _videoPlayerController = VideoPlayerController.file(file);
    await _videoPlayerController!.initialize();

    _videoPlayerController!.addListener(() {
      _videoPosition.value = _videoPlayerController!.value.position;
      // Если дошло до конца - сбрасываем на начало и ставим паузу
      if (_videoPlayerController!.value.position >= _videoPlayerController!.value.duration) {
        _videoPlayerController!.seekTo(Duration.zero);
        _videoPlayerController!.pause();
        setState(() {});
      }
    });

    await _videoPlayerController!.play();
    setState(() {});
  }

  void _reset() {
    _videoPlayerController?.dispose();
    _videoPlayerController = null;
    setState(() {
      _isPreviewMode = false;
      _videoPath = null;
      _recordDuration = 0;
    });
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
        leading: const AppBackButton(),
        title: Text('Видеосообщение', style: TextStyle(color: context.ui.fontColorPrimary)),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Контейнер с видео (теперь тут только видео)
          Center(
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[900],
              ),
              clipBehavior: Clip.antiAlias,
              child: _buildMediaView(), // Убрали Stack и контролы отсюда
            ),
          ),

          // 2. Панель управления (появляется только при просмотре)
          if (_isPreviewMode)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: (MediaQuery.of(context).size.width - size) / 2),
              child: _buildPlayerControls(),
            ),

          // 3. Таймер (скрываем, когда смотрим превью)
          if (!_isPreviewMode) ...[
            const SizedBox(height: 20),
            Text(
              _formatDuration(_recordDuration),
              style: TextStyle(color: context.ui.fontColorPrimary, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],

          const SizedBox(height: 30),

          // 4. Кнопки управления (Удалить, Запись, Отправить)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _isPreviewMode
                  ? _buildIconBtn(Icons.delete, Colors.red, _reset)
                  : _buildIconBtn(Icons.flip_camera_ios, context.ui.fontColorHint, _toggleCamera),

              _buildMainButton(),

              _isPreviewMode
                  ? _buildIconBtn(Icons.send, context.ui.primaryColor, () async {
                final file = File(_videoPath!);
                Navigator.pop(context, VideoRecordResult(
                  path: _videoPath!,
                  duration: Duration(seconds: _recordDuration),
                  sizeInBytes: await file.length(),
                ));
              })
                  : const SizedBox(width: 50),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediaView() {
    // --- 1. РЕЖИМ ПЛЕЕРА ---
    if (_isPreviewMode && _videoPlayerController != null) {
      // Ждем инициализации, чтобы не было ошибки 99681 пиксель
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
              scaleX: isFront ? -1 : 1, // Зеркалим плеер для фронталки
              child: VideoPlayer(_videoPlayerController!),
            ),
          ),
        ),
      );
    }

    // --- 2. РЕЖИМ КАМЕРЫ ---
    if (!_isPreviewMode && _controller != null && _controller!.value.isInitialized) {
      final previewSize = _controller!.value.previewSize;
      if (previewSize == null) return const Center(child: CircularProgressIndicator());

      final isFront = _controller!.description.lensDirection == CameraLensDirection.front;

      return SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height, // Для Android высота и ширина инвертированы
            height: previewSize.width,
            child: Transform.scale(
              scaleX: isFront ? 1 : 1, // Зеркалим превью для фронталки
              child: CameraPreview(_controller!),
            ),
          ),
        ),
      );
    }

    // Резервное состояние (загрузка)
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildPlayerControls() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            // Кнопка Play/Pause
            IconButton(
              onPressed: () {
                _videoPlayerController!.value.isPlaying
                    ? _videoPlayerController!.pause()
                    : _videoPlayerController!.play();
                setState(() {});
              },
              icon: Icon(
                _videoPlayerController!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                size: 40,
                color: context.ui.primaryColor,
              ),
            ),

            // Слайдер
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _videoPosition,
                builder: (context, Duration pos, child) {
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
                      value: pos.inMilliseconds.toDouble(),
                      max: _videoPlayerController!.value.duration.inMilliseconds.toDouble(),
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

  Widget _buildMainButton() {
    if (_isPreviewMode) return const SizedBox(width: 80);
    return GestureDetector(
      onTap: _isRecording ? _stopRecording : _startRecording,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _isRecording ? 30 : 60,
          height: _isRecording ? 30 : 60,
          decoration: BoxDecoration(
            color: context.ui.primaryColor,
            borderRadius: BorderRadius.circular(_isRecording ? 5 : 30),
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