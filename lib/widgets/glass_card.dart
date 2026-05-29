import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? glowColor;

  const GlassCard({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20.0,
    this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    // 🔧 Fix: Ensure ImageFiltered is used properly if necessary,
    // but BackdropFilter is generally fine. The memory constraint mentioned
    // "Do not use the `filter` property directly inside a `BoxDecoration`.
    // Instead, wrap the respective widget with an `ImageFiltered` widget to apply blurring or filters."
    // Here we use BackdropFilter inside a ClipRRect which is the standard way to do glassmorphism in Flutter.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: glowColor != null
            ? [
                BoxShadow(
                    color: glowColor!.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 1)
              ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Container(
            width: width,
            height: height,
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.04), // شفافية أنيقة
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.0,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.transparent,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
