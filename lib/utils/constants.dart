import 'package:flutter/material.dart';

class AppConstants {
  // مسافات وقياسات
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 20.0;
  static const double iconSize = 28.0;

  // مدد الأنيميشن
  static const Duration quickAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 600);
  static const Duration slowAnimation = Duration(milliseconds: 1000);

  // رسائل عامة
  static const String appName = 'Sadeem (سديم)';
  static const String errorGeneric = 'حدث خطأ غير متوقع، حاول مرة أخرى.';
}