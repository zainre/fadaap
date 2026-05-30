import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'; // نحتاج هذه المكتبة لحركة زر سديم

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 75, // زيادة طفيفة لراحة الإصبع
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.65),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.15), width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_filled, Icons.home_outlined, 0),
              _buildNavItem(Icons.search, Icons.search_outlined, 1),
              _buildSadeemCenterButton(2), // ✨ زر سديم المركزي الأسطوري
              _buildNavItem(
                  Icons.video_library, Icons.video_library_outlined, 3),
              _buildNavItem(Icons.person, Icons.person_outline, 4),
            ],
          ),
        ),
      ),
    );
  }

  // ✨ زر سديم المركزي (AI Centerpiece)
  Widget _buildSadeemCenterButton(int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amberAccent.withOpacity(0.2)
              : Colors.amberAccent.withOpacity(0.05),
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 2),
                  BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5),
                ]
              : [
                  BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1),
                ],
          border: Border.all(
            color: isActive ? Colors.amberAccent : Colors.amberAccent.withOpacity(0.5),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Icon(
          Icons.auto_awesome, // Changed to a more AI-oriented icon
          color: isActive ? Colors.white : Colors.amberAccent.withOpacity(0.8),
          size: 36, // Larger to stand out
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(duration: 2.seconds, color: Colors.white)
        .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.1, 1.1),
            duration: 2.seconds),
      ),
    );
  }

  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              color: isActive ? Colors.white : Colors.white54,
              size: 28,
            ),
          ),
          // ✨ مؤشر الإضاءة السفلي
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 3,
            width: isActive ? 15 : 0,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 4)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
