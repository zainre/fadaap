import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color blackColor = Colors.black;
  static const Color whiteColor = Colors.white;
  static const Color darkGrey = Color(0xFF1A1A1A);
  static const Color lightGrey = Color(0xFFE0E0E0);

  // الثيم الموحد (أسود وأبيض)
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: whiteColor,
      scaffoldBackgroundColor: blackColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: blackColor,
        elevation: 0,
        iconTheme: IconThemeData(color: whiteColor),
        titleTextStyle: TextStyle(
          color: whiteColor,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: GoogleFonts.cairoTextTheme(
        ThemeData.dark().textTheme,
      ).copyWith(
        displayLarge: const TextStyle(color: whiteColor, fontWeight: FontWeight.bold),
        bodyLarge: const TextStyle(color: whiteColor, fontSize: 16),
        bodyMedium: const TextStyle(color: lightGrey, fontSize: 14),
      ),
      iconTheme: const IconThemeData(color: whiteColor),
      buttonTheme: const ButtonThemeData(
        buttonColor: whiteColor,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: whiteColor,
          foregroundColor: blackColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // حواف دائرية ناعمة
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 5,
        ),
      ),
      // أنيميشن مدمج عند الانتقال بين الصفحات ليكون سلساً
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}