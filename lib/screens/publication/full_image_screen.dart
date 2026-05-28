import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dia_room/components/loading_widget/loader_widget.dart';
import 'package:dia_room/utils/app_theme.dart';
import 'package:flutter/material.dart';
import '../../components/general/app_back_button.dart';
import '../../models/enums/file_type.dart';

class FullImageScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final FileType type;

  const FullImageScreen({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    this.type = FileType.network,
  });

  @override
  State<FullImageScreen> createState() => _FullImageScreenState();
}

class _FullImageScreenState extends State<FullImageScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  double _dragOffset = 0.0;

  // Флаг: увеличен ли сейчас масштаб картинки
  bool _isZoomed = false;

  // Контроллеры для управления зумом и его анимацией
  final TransformationController _transformationController = TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _zoomAnimation;

  // Сохраняем позицию пальца при тапе, чтобы зумить именно в это место
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Слушаем изменение масштаба картинки
    _transformationController.addListener(() {
      final scale = _transformationController.value.getMaxScaleOnAxis();
      // Если масштаб больше 1.0 (с небольшой погрешностью), значит есть зум
      final isZoomed = scale > 1.001;

      if (_isZoomed != isZoomed) {
        setState(() {
          _isZoomed = isZoomed;
        });
      }
    });

    // Настраиваем анимацию для двойного тапа
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
      if (_zoomAnimation != null) {
        _transformationController.value = _zoomAnimation!.value;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _handleDoubleTapDown(TapDownDetails details) {
    _doubleTapDetails = details;
  }

  void _handleDoubleTap() {
    if (_animationController.isAnimating) return;

    final currentMatrix = _transformationController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();

    Matrix4 targetMatrix;

    if (currentScale > 1.001) {
      // Если уже есть какой-то зум -> возвращаем в исходное положение
      targetMatrix = Matrix4.identity();
    } else {
      // Если исходное положение -> зумим в 1.5 раза в точку тапа
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      const targetScale = 1.5;

      // Рассчитываем сдвиг, чтобы зум произошел ровно под пальцем
      final x = -position.dx * (targetScale - 1);
      final y = -position.dy * (targetScale - 1);

      targetMatrix = Matrix4.identity()
        ..translate(x, y)
        ..scale(targetScale);
    }

    // Запускаем плавную анимацию матрицы трансформации
    _zoomAnimation = Matrix4Tween(
      begin: currentMatrix,
      end: targetMatrix,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));

    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Отключаем вертикальный свайп на закрытие, если картинка увеличена
        onVerticalDragUpdate: _isZoomed ? null : (details) {
          setState(() {
            _dragOffset += details.primaryDelta ?? 0;
          });
        },
        onVerticalDragEnd: _isZoomed ? null : (details) {
          if (_dragOffset < -150 || details.primaryVelocity! < -800) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _dragOffset = 0.0;
            });
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Transform.translate нужен, чтобы картинка двигалась вверх/вниз при свайпе
            Transform.translate(
              offset: Offset(0, _dragOffset),
              child: PageView.builder(
                controller: _pageController,
                // Отключаем свайпы влево/вправо у PageView, если картинка увеличена
                physics: _isZoomed
                    ? const NeverScrollableScrollPhysics()
                    : const BouncingScrollPhysics(),
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    // Сбрасываем зум при перелистывании на следующую картинку
                    _transformationController.value = Matrix4.identity();
                  });
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: GestureDetector(
                      onDoubleTapDown: _handleDoubleTapDown,
                      onDoubleTap: _handleDoubleTap,
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        panEnabled: true, // Включает перемещение (пан)
                        // boundaryMargin: EdgeInsets.zero не даст утащить фото за пределы экрана
                        boundaryMargin: EdgeInsets.zero,
                        minScale: 1.0, // Не дает уменьшить фото меньше оригинала
                        maxScale: 4.0,
                        child: _buildImage(widget.imageUrls[index]),
                      ),
                    ),
                  );
                },
              ),
            ),

            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 10,
              child: AppBackButton(color: context.ui.elementsVideoPlayerColor),
            ),

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
        placeholder: (context, url) => Center(
          child: DiaRoomLoader(color: context.ui.elementsPhotoViewerColor,),
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