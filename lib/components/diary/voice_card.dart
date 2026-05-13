import 'package:audioplayers/audioplayers.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';

import '../../contracts/diary/response/getting_messages.dart';

class VoiceMessageBubble extends StatefulWidget {
  final MessagePresentation message;

  const VoiceMessageBubble({super.key, required this.message});

  @override
  State<VoiceMessageBubble> createState() => _VoiceMessageBubbleState();
}

class _VoiceMessageBubbleState extends State<VoiceMessageBubble> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Берем данные из вложения (duration там в миллисекундах)
    if (widget.message.attachments.isNotEmpty) {
      final att = widget.message.attachments.first;
      _duration = Duration(milliseconds: att.duration!);
    }

    // Слушаем изменения плеера
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _position = Duration.zero);
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      final url = widget.message.attachments.first.s3Key;
      await _audioPlayer.play(UrlSource(url));
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
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

          const SizedBox(width: 12),

          // Полоса воспроизведения и время
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Длительность над полоской
                Text(
                  _formatDuration(_isPlaying ? _position : _duration),
                  style: TextStyle(
                    fontSize: 12,
                    color: context.ui.fontColorPrimary.withOpacity(0.7),
                  ),
                ),

                // Слайдер (перемотка)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: context.ui.primaryColor,
                    inactiveTrackColor: context.ui.primaryColor.withOpacity(0.2),
                    thumbColor: context.ui.primaryColor,
                  ),
                  child: Slider(
                    min: 0,
                    max: _duration.inMilliseconds.toDouble() > 0
                        ? _duration.inMilliseconds.toDouble()
                        : 1.0,
                    value: _position.inMilliseconds.toDouble().clamp(
                        0,
                        _duration.inMilliseconds.toDouble()
                    ),
                    onChanged: (value) async {
                      await _audioPlayer.seek(Duration(milliseconds: value.toInt()));
                    },
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