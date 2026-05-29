import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color darkGrey = Color(0xFF121212); // لون أغمق لعمق أكبر
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color sadeemAccent = Colors.amberAccent; // ✨ لون سديم التفاعلي

  // الثيم الموحد الفخم
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: whiteColor,
      scaffoldBackgroundColor: blackColor,
      colorScheme: const ColorScheme.dark(
        primary: whiteColor,
        secondary: sadeemAccent, // استخدام اللون الذهبي كلون ثانوي للحركات
      ),

      // إعدادات الـ AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: blackColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: TextStyle(
          color: whiteColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),

      // الخطوط (Arabic Typography)
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge:
            const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: whiteColor, fontSize: 16),
        bodyMedium: const TextStyle(color: lightGrey, fontSize: 14),
      ),

      // الأيقونات
      iconTheme: const IconThemeData(color: whiteColor, size: 26),

      // الأزرار
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor,
          foregroundColor: blackColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 5,
        ),
      ),

      // ✨ تصميم حقول الإدخال (TextForms) لتبدو عصرية وزجاجية
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        labelStyle: TextStyle(color: Colors.grey.shade500),
        hintStyle: TextStyle(color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: sadeemAccent, width: 1.5),
        ),
      ),

      // ✨ إعدادات النوافذ المنبثقة (Bottom Sheets) لدعم الـ Glassmorphism
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    );
  }
}
