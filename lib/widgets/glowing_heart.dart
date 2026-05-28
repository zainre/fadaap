import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlowingHeart extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onTap;
  final double size;

  const GlowingHeart({
    super.key,
    required this.isLiked,
    required this.onTap,
    this.size = 28.0,
  });

  @override
  State<GlowingHeart> createState() => _GlowingHeartState();
}

class _GlowingHeartState extends State<GlowingHeart> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void didUpdateWidget(covariant GlowingHeart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLiked != oldWidget.isLiked) {
      if (widget.isLiked) {
        _controller.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final scale = 1.0 + (_controller.value * 0.3); // تكبير عند الضغط
          return Transform.scale(
            scale: widget.isLiked ? scale : 1.0,
            child: Icon(
              widget.isLiked ? Icons.favorite : Icons.favorite_border,
              color: Colors.white, // أبيض دائماً حسب طلبك
              size: widget.size,
            ),
          );
        },
      )
      .animate(target: widget.isLiked ? 1 : 0)
      .boxShadow(
        begin: const BoxShadow(color: Colors.transparent),
        end: BoxShadow(color: Colors.white.withOpacity(0.6), blurRadius: 15, spreadRadius: 2), // توهج أبيض فخم
        duration: 300.ms,
      ),
    );
  }
}