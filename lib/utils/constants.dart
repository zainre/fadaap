import 'package:flutter/material.dart';

class AppConstants {
  // مسافات وقياسات
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 20.0;
  static const double iconSize = 28.0;

  // مدد الأنيميشن (تمت إضافة حركات سديم السحرية)
  static const Duration quickAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration slowAnimation = Duration(milliseconds: 1000);
  static const Duration magicAnimation = Duration(milliseconds: 2000);

  // ألوان سديم المميزة
  static const Color sadeemNeon = Colors.amberAccent;
  static const Color glassBorder = Colors.white24;

  // رسائل عامة وهوية التطبيق
  static const String appName = 'Sadeem (سديم)';
  static const String errorGeneric = 'حدث خطأ غير متوقع، سديم يحاول الإصلاح.';
  static const String aiThinking = 'سديم يحلل البيانات... ✨';

  // 👑 بصمة المطور الأسطورية (تُستدعى في الشاشات كـ Easter Egg)
  static const String zainSignature = '✨ Crafted with magic by Zain';
  static const String devEmail = 'zainalabdeensalman123@gmail.com';
}
