import 'package:flutter/material.dart';

class AnimatedStoryCircle extends StatefulWidget {
  final String imageUrl;
  final VoidCallback onTap;
  final double size;
  final bool hasUnviewedStory;

  const AnimatedStoryCircle({
    super.key,
    required this.imageUrl,
    required this.onTap,
    this.size = 70.0,
    this.hasUnviewedStory = true,
  });

  @override
  State<AnimatedStoryCircle> createState() => _AnimatedStoryCircleState();
}

class _AnimatedStoryCircleState extends State<AnimatedStoryCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3), // أسرع قليلاً لجذب الانتباه
    )..repeat();
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
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ✨ الإطار الكوني المتحرك (Sadeem Cosmic Gradient)
          if (widget.hasUnviewedStory)
            RotationTransition(
              turns: _controller,
              child: Container(
                width: widget.size + 8,
                height: widget.size + 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: SweepGradient(
                    colors: [
                      Colors.amberAccent,
                      Colors.purpleAccent,
                      Colors.blueAccent,
                      Colors.amberAccent // العودة لنفس اللون لضمان دوران سلس
                    ],
                    stops: [0.0, 0.33, 0.66, 1.0],
                  ),
                ),
              ),
            ),

          // فاصل أسود لبروز الصورة
          Container(
            width: widget.size + 4,
            height: widget.size + 4,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
          ),

          // صورة المستخدم
          Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade900,
              image: DecorationImage(
                image: NetworkImage(widget.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
