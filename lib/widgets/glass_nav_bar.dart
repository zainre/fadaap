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

  // ✨ زر سديم المركزي
  Widget _buildSadeemCenterButton(int index) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.amberAccent.withOpacity(0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: Colors.amberAccent.withOpacity(0.2),
                      blurRadius: 15)
                ]
              : [],
        ),
        child: Icon(
          Icons.blur_on, // أيقونة سديم
          color: isActive ? Colors.amberAccent : Colors.white70,
          size: 34, // أكبر قليلاً من الأزرار العادية
        ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1.05, 1.05),
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
