import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF151515), // أسود أعمق
      highlightColor: const Color(0xFF2A2A2A), // رمادي معدني
      // ✨ إضافة لون سديم الذهبي كلمسة خفية في الوميض
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.black, // اللون الأساسي للشكل
          borderRadius: BorderRadius.circular(borderRadius),
          border:
              Border.all(color: Colors.white.withOpacity(0.02)), // حد خفيف جداً
        ),
      ),
    );
  }
}
