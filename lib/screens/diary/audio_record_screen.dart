import 'dart:async';
import 'dart:io';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../components/general/app_back_button.dart';

class VoiceRecordResult {
  final String path;
  final Duration duration;

  VoiceRecordResult({
    required this.path,
    required this.duration,
  });
}

class AudioRecordScreen extends StatefulWidget {
  const AudioRecordScreen({super.key});

  @override
  State<AudioRecordScreen> createState() => _AudioRecordScreenState();
}

class _AudioRecordScreenState extends State<AudioRecordScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  // Плеер и его состояние
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  bool _isRecording = false;
  bool _isPaused = false;
  String? _path;

  Timer? _timer;
  int _recordDuration = 0;

  @override
  void initState() {
    super.initState();

    // Слушаем состояние плеера
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() => _isPlaying = state == PlayerState.playing);
      }
    });

    _audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _position = Duration.zero;
          _isPlaying = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose(); // Не забываем освобождать ресурсы
    super.dispose();
  }

  // --- Логика воспроизведения ---
  Future<void> _playPause() async {
    if (_path == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_path!));
    }
  }

  // --- Управление записью ---
  Future<void> _start() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getApplicationCacheDirectory();
        final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

        const recordConfig = RecordConfig(
          encoder: AudioEncoder.aacLc, // AAC — лучший баланс между сжатием и качеством
          bitRate: 32000,              // 32 kbps
          sampleRate: 22050,           // 22.05 kHz — стандарт для речи
          numChannels: 1,              // Моно
          autoGain: true,              // Авто-усиление: выравнивает тихий голос
          echoCancel: true,            // Эхоподавление
          noiseSuppress: true,         // Шумоподавление
        );

        await _audioRecorder.start(recordConfig, path: path);

        setState(() {
          _isRecording = true;
          _isPaused = false;
          _recordDuration = 0;
          _path = null;
        });
        _startTimer();
      }
    } catch (e) {
      print("Ошибка старта: $e");
    }
  }

  Future<void> _stop() async {
    _stopTimer();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _isPaused = false;
      _path = path;
    });
    // Загружаем файл в плеер сразу после остановки, чтобы получить длительность
    if (path != null) {
      await _audioPlayer.setSourceDeviceFile(path);
    }
  }

  void _reset() {
    _audioPlayer.stop();
    if (_path != null) {
      final file = File(_path!);
      if (file.existsSync()) file.deleteSync();
    }
    setState(() {
      _path = null;
      _recordDuration = 0;
      _isRecording = false;
      _isPaused = false;
      _position = Duration.zero;
    });
  }

  // --- Вспомогательные методы ---
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _recordDuration++);
    });
  }

  void _stopTimer() => _timer?.cancel();

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.ui.appBarColor,
        elevation: 0,
        leading: const AppBackButton(),
        title: Text(
          'Голосовое сообщение',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: context.ui.fontColorPrimary,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Таймер записи или Плеер
            if (_path == null) ...[
              Text(
                _formatDuration(Duration(seconds: _recordDuration)),
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w300,
                  color: context.ui.fontColorPrimary,
                  letterSpacing: 2,
                ),
              ),
            ] else ...[
              _buildPlayerUI(), // Показываем плеер, если запись готова
            ],

            const SizedBox(height: 10),
            Text(
              _path != null
                  ? "Запись готова"
                  : (_isRecording ? (_isPaused ? "На паузе" : "Запись...") : "Готов к записи"),
              style: TextStyle(color: context.ui.primaryColor, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 60),

            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_path != null || _isRecording)
                  _buildActionButton(
                    icon: Icons.delete_outline,
                    color: Colors.redAccent,
                    onTap: _reset,
                  ),

                const SizedBox(width: 20),
                _buildMainButton(),
                const SizedBox(width: 20),

                if (_isRecording && _path == null)
                  _buildActionButton(
                    icon: _isPaused ? Icons.play_arrow : Icons.pause,
                    color: Colors.orange,
                    onTap: _isPaused ? _resume : _pause,
                  ),

                if (!_isRecording && _path != null)
                  _buildActionButton(
                    icon: Icons.send_rounded,
                    color: context.ui.primaryColor,
                    onTap: () => Navigator.pop(context, VoiceRecordResult(
                      path: _path!,
                      duration: _duration,
                    ),),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Виджет плеера (Слайдер + время)
  Widget _buildPlayerUI() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(_position), style: TextStyle(color: context.ui.fontColorHint)),
            Text(_formatDuration(_duration), style: TextStyle(color: context.ui.fontColorHint)),
          ],
        ),
        Slider(
          min: 0,
          max: _duration.inMilliseconds.toDouble() > 0
              ? _duration.inMilliseconds.toDouble()
              : 1.0,
          value: _position.inMilliseconds.toDouble(),
          activeColor: context.ui.primaryColor,
          inactiveColor: context.ui.primaryColor.withOpacity(0.2),
          onChanged: (value) async {
            final position = Duration(milliseconds: value.toInt());
            await _audioPlayer.seek(position);
          },
        ),
        IconButton(
          iconSize: 64,
          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          color: context.ui.primaryColor,
          onPressed: _playPause,
        ),
      ],
    );
  }

  Widget _buildMainButton() {
    bool showStop = _isRecording;
    // Если запись готова, центральная кнопка может либо ничего не делать, либо перезаписывать
    return GestureDetector(
      onTap: _path != null ? null : (showStop ? _stop : _start),
      child: Opacity(
        opacity: _path != null ? 0.3 : 1.0, // Скрываем, если уже записали
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: showStop ? Colors.red : context.ui.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            showStop ? Icons.stop : Icons.mic_none_rounded,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required VoidCallback onTap}) {
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

  // Методы паузы/продолжения записи (нужны для кнопок)
  Future<void> _pause() async {
    await _audioRecorder.pause();
    _stopTimer();
    setState(() => _isPaused = true);
  }

  Future<void> _resume() async {
    await _audioRecorder.resume();
    _startTimer();
    setState(() => _isPaused = false);
  }
}