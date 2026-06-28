import 'dart:math';

import 'package:flutter/material.dart';

import 'loader_painter.dart';

class DiaRoomLoader extends StatefulWidget {
  final Color color;
  final double size;

  const DiaRoomLoader({
    super.key,
    this.color = const Color(0xFF722323),
    this.size = 40.0,
  });

  @override
  State<DiaRoomLoader> createState() => _DiaRoomLoaderState();
}

class _DiaRoomLoaderState extends State<DiaRoomLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: DiaRoomLoaderPainter(
                color: widget.color,
              ),
            ),
          );
        },
      ),
    );
  }
}